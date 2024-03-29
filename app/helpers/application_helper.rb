module ApplicationHelper
  def base_meta_tags
    {
      site: 'Atlier',
      reverse: true,
      charset: 'utf-8',
      description: "作品記録・共有型SNS Atlier - Atlierはクリエイターの為のSNSです。
                    クリエイターとの繋がりや作品の制作意図を正しく共有できる場を提供します！",
      canonical: request.original_url,
      separator: ' - ',
      icon: image_url("favicon.ico"),
      og: base_og,
    }
  end

  def current_user?(user)
    user == current_user
  end

  def text_url_to_link(text)
    URI.extract(text, ["http", "https"]).uniq.each do |url|
      sub_text = ""
      sub_text << "<a href=" << url << " target=\"_blank\" rel=\"noopener\">" << url << "</a>"
      text.gsub!(url, sub_text)
    end
    text
  end

  def display_avatar_for(user, size: Settings.avatar_size[:in_feed])
    resize = "#{size}x#{size}^"
    crop = "#{size}x#{size}+0+0"

    if user.avatar.attached?
      image = user.avatar.variant(
        gravity: :center,
        resize: resize,
        crop: crop,
      ).processed
      alt = user.username

      return image_tag(image, alt: alt, class: "avatar")
    else
      return image_tag("avatar.png", alt: "default", class: "avatar", size: resize)
    end
  end

  def unchecked_notifications
    current_user.passive_notifications.where(checked: false)
  end

  private

  def base_og
    {
      title: :full_title,
      description: :description,
      url: request.original_url,
      image: image_url("card.png"),
    }
  end
end
