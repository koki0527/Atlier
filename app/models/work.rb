class Work < ApplicationRecord
  default_scope -> { order(created_at: :desc) }
  after_create { Footprint.create(user_id: user_id, work_id: id, counts: 0) }

  # Relations
  has_one_attached :image
  belongs_to :user
  belongs_to :category
  has_many :comments, dependent: :destroy
  has_many :illustrations, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :notifications, dependent: :destroy
  has_many :footprints, dependent: :destroy
  has_many :stocks, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  # Validation
  validates :user_id,
    presence: true
  validates :title,
    presence: true,
    length: { maximum: 50 }
  validates :concept,
    length: { maximum: 300 }
  validates :description,
    length: { maximum: 300 }
  validates :image,
    content_type: {
      in: %w(image/jpeg image/gif image/png), message: "有効なファイルを選択してください"
    },
    size: {
      less_than: 5.megabytes, message: "5MB以下を選択してください"
    },
    presence: { message: 'を添付してください。' }

  def display_image_square(size: 600, main: false)
    if main
      image.variant(gravity: :center, resize: "600x600^", crop: "848x600+0+0").processed
    else
      image.variant(gravity: :center, resize: "#{size}x#{size}^", crop: "#{size}x#{size}+0+0").processed
    end
  end

  def create_notification_like(current_user)
    temp = Notification.where(
      [
        "visitor_id = ? and visited_id = ? and work_id = ? and action = ? ",
        current_user.id,
        user_id,
        id,
        'like',
      ]
    )
    if temp.blank?
      notification = current_user.active_notifications.new(
        work_id: id,
        visited_id: user_id,
        action: 'like',
      )
      if notification.visitor_id == notification.visited_id
        notification.checked = true
      end
      notification.save if notification.valid?
    end
  end

  def create_notification_comment(current_user, comment_id)
    temp = Comment.
      select(:user_id).
      where(work_id: id).
      where.not(user_id: current_user.id).
      distinct
    temp_ids = [user.id]
    temp.each { |i| temp_ids << i.user_id }
    temp_ids.each do |temp_id|
      save_notification_comment(current_user, comment_id, temp_id)
    end
  end

  def save_notification_comment(current_user, comment_id, visited_id)
    unless current_user.id == visited_id
      notification = current_user.active_notifications.new(
        work_id: id,
        comment_id: comment_id,
        visited_id: visited_id,
        action: 'comment'
      )
      notification.save if notification.valid?
    end
  end

  def create_footprint_by(user)
    if Footprint.find_by(user_id: user.id, work_id: id).present?
      footprint = Footprint.find_by(user_id: user.id, work_id: id)
      counts = footprint.counts
      footprint.update_attribute(:counts, counts + 1)
    else
      Footprint.create(user_id: user.id, work_id: id)
    end
  end
end
