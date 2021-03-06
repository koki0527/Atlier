require "rails_helper"

RSpec.describe "Liked work", type: :system, js: true do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:third_user) { create(:user) }
  let(:work) { create(:work, user: user) }
  let(:another_work) { create(:work, user: user) }
  let!(:like) { create(:like, user: another_user, work: work) }
  let!(:like_by_third_user) { create(:like, user: third_user, work: work) }
  let!(:current_count) { work.likes.count }
  let(:liked) { Like.find_by(user_id: user.id, work_id: work.id) }

  it "display and create, destroy likes" do
    sign_in user
    visit work_path work
    within("div#likes_button-#{work.id}") do
      expect(page).to have_link href: work_likes_path(work)
      expect(page).to have_selector ".likes_count", text: "#{current_count}"
      find(".like_btn").click
    end
    within("div#likes_button-#{work.id}") do
      expect(page).to have_link href: work_like_path(work, liked)
      expect(page).to have_selector ".likes_count", text: "#{current_count + 1}"
      find(".like_btn").click
    end
    within("div#likes_button-#{work.id}") do
      expect(page).to have_link href: work_likes_path(work)
      expect(page).to have_selector ".likes_count", text: "#{current_count}"
    end
  end

  it "change display of works" do
    sign_in user
    visit user_path user
    within("section.user--works") do
      within("#work-#{work.id}") do
        expect(page).to have_selector ".work--title", text: "#{work.title}"
      end
      within(".user--works__types") do
        expect(page.all("input.btn__works").count).to eq 2
        click_button "お気に入り"
      end
    end
    within(".user--works__favorites") do
      expect(page).to have_selector "h4", text: "いいねした作品がありません"
    end
    visit user_path another_user
    within(".user--works__types") { click_button "お気に入り" }
    within(".user--works__favorites") do
      within("#work-#{work.id}") do
        expect(page).to have_selector ".work--title", text: "#{work.title}"
      end
    end
  end
end
