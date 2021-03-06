require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Validatioins test" do
    subject { user }

    let(:user) { build(:user) }

    context "user has valid information" do
      let(:user) { build(:user, username: "example", email: "test@exmpale.com") }
      it { is_expected.to be_valid }
    end

    context "user doesnt have name" do
      let(:user) { build(:user, username: " ") }
      it { is_expected.not_to be_valid }
    end

    context "user doesnt have email" do
      let(:user) { build(:user, email: " ") }
      it { is_expected.not_to be_valid }
    end

    context "user has too long name" do
      let(:user) { build(:user, username: "a" * 51) }
      it { is_expected.not_to be_valid }
    end

    context "user has too long email" do
      let(:user) { build(:user, email: "a" * 244 + "@example.com") }
      it { is_expected.not_to be_valid }
    end

    context "user has valid email" do
      valid_emails = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn)
      valid_emails.each do |email|
        let(:user) { build(:user, email: email) }
        it { is_expected.to be_valid }
      end
    end

    context "user has invalid email" do
      invalid_emails = %w(user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com)
      invalid_emails.each do |email|
        let(:user) { build(:user, email: email) }
        it { is_expected.not_to be_valid }
      end
    end

    context "user has same email" do
      let(:origin_user) { create(:user, email: "test@exmpale.com") }
      let(:user) { build(:user, email: origin_user.email) }
      it { is_expected.not_to be_valid }
    end

    context "user has blank password" do
      let(:password) { " " * 8 }
      let(:user) { build(:user, password: password, password_confirmation: password) }
      it { is_expected.not_to be_valid }
    end

    context "user has short password" do
      let(:password) { "a" * 7 }
      let(:user) { build(:user, password: password, password_confirmation: password) }
      it { is_expected.not_to be_valid }
    end

    context "user has missmatch of password and password_confirmation" do
      let(:password) { "password" }
      let(:password_confirmation) { "abcd1234" }
      let(:user) { build(:user, password: password, password_confirmation: password_confirmation) }
      it { is_expected.not_to be_valid }
    end

    context "user has too long description" do
      let(:description) { "a" * 251 }
      let(:user) { build(:user, description: description) }
      it { is_expected.not_to be_valid }
    end

    context "user has too long url" do
      let(:website) { "https://" + "a" * 143 }
      let(:user) { build(:user, website: website) }
      it { is_expected.not_to be_valid }
    end

    context "user has invalid url" do
      invalid_url = %w(hhtps://abc //abc https:/aaaa)
      invalid_url.each do |website|
        let(:user) { build(:user, website: website) }
        it { is_expected.not_to be_valid }
      end
    end

    context "user has valid url" do
      valid_url = %w(http://example.com/ http://example/example http://example?q=ABC&oq=ABC)
      valid_url.each do |website|
        let(:user) { build(:user, website: website) }
        it { is_expected.to be_valid }
      end
    end
  end

  describe "Test related to other model" do
    context "destroyed user has work" do
      let!(:user) { create(:user) }
      let!(:work) { create(:work, user: user) }
      let!(:count) { Work.count }
      it "work related to user are destroyed" do
        user.destroy
        expect(Work.count).to eq count - 1
      end
    end

    context "destroyed user has comment" do
      let!(:user) { create(:user) }
      let!(:comment) { create(:comment, user: user) }
      let!(:count) { Comment.count }
      it "comment related to user are destroyed" do
        user.destroy
        expect(Comment.count).to eq count - 1
      end
    end
  end

  describe "Method test" do
    describe "follow method" do
      subject { user.following?(another_user) }

      let(:user) { create(:user) }
      let(:another_user) { create(:user) }

      context "user doesnt follow another_user" do
        it "following? return false" do
          is_expected.to be_falsey
        end
      end

      context "user follow another_user" do
        before { user.follow(another_user) }

        it "following? return true" do
          is_expected.to be_truthy
        end

        it "followed by user" do
          expect(another_user.followers.include?(user)).to be_truthy
        end
      end

      context "user unfollow another_user" do
        before { user.follow(another_user) }

        it "following? return true" do
          user.unfollow(another_user)
          is_expected.to be_falsey
        end
      end
    end

    describe "feed method" do
      subject { user1.feed }

      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:user3) { create(:user) }
      let!(:works_by_user1) { create_list(:work, 20, user: user1) }
      let!(:works_by_user2) { create_list(:work, 20, user: user2) }
      let!(:works_by_user3) { create_list(:work, 20, user: user3) }

      before do
        sign_in user1
        user1.follow(user2)
      end

      it "include my works" do
        user1.works.each do |work|
          expect(user1.feed).to include(work)
        end
      end

      it "include followed works" do
        user2.works.each do |work|
          expect(user1.feed).to include(work)
        end
      end

      it "not include not followed works" do
        user3.works.each do |work|
          expect(user1.feed).not_to include(work)
        end
      end
    end

    describe "already_commented? method" do
      let(:user) { create(:user) }
      let(:work_commented) { create(:work) }
      let(:work_not_commented) { create(:work) }
      let!(:comment) { create(:comment, user_id: user.id, work_id: work_commented.id) }

      it "return true because user commented" do
        expect(user.already_commented?(work_commented)).to be_truthy
      end

      it "return false because user doesnt commented yet" do
        expect(user.already_commented?(work_not_commented)).to be_falsey
      end
    end

    describe "already_liked? method" do
      let(:user) { create(:user) }
      let(:work_liked) { create(:work) }
      let(:work_not_liked) { create(:work) }
      let!(:like) { create(:like, user_id: user.id, work_id: work_liked.id) }

      it "return true because user liked" do
        expect(user.already_liked?(work_liked)).to be_truthy
      end

      it "return false because user doesnt liked yet" do
        expect(user.already_liked?(work_not_liked)).to be_falsey
      end
    end

    describe "create_notification_follow method" do
      let(:user) { create(:user) }
      let(:another_user) { create(:user) }
      let(:notification) { Notification.find_by(visitor_id: another_user.id, visited_id: user.id, action: "follow") }

      before do
        another_user.follow(user)
        user.create_notification_follow(another_user)
      end

      it "create notification to user" do
        expect(notification).to be_truthy
      end

      it "not create notification to user twice" do
        expect(user.create_notification_follow(another_user)).to be_nil
      end
    end
  end
end
