require 'rails_helper'

RSpec.describe 'Users profile', type: :system do
  describe "User profile test" do
    let!(:user) { create(:user) }
    let!(:works) { create_list(:work, 21, user: user) }
    before do
      sign_in user
    end

    it "profile information display correctly" do
      visit user_path user
      within(".user--info") do
        expect(page).to have_selector "img[alt='#{user.username}']"
        expect(page).to have_selector "h1", text: "#{user.username}"
      end
      within(".user--works") do
        within(".user--works__types") do
          expect(page.all("input.btn__works").count).to eq 2
        end
        user.works.page(1) do |work|
          expect(page).to have_selector "img.avatar"
          expect(page).to have_selector ".user", text: "#{work.user.name}"
          expect(page).to have_selector ".title", text: "#{work.title}"
          expect(page).to have_selector ".concept", text: "#{work.concept}"
        end
        expect(page).to have_selector "ul.pagination"
      end
    end
  end
end
