require 'rails_helper'

RSpec.describe 'Works interface', type: :system do
  let(:user) { create(:user) }
  let!(:works) { create_list(:work, 21, user: user) }
  let!(:current_work) { works[20] }
  let!(:illustrations) { create_list(:illustration, 5, work: current_work) }

  it "check work feed has links correctly" do
    sign_in user
    visit root_path
    within(".pagination") do
      expect(page).to have_link href: '/?page=2'
    end
    within("ol.works") do
      works[1..20].each do |work|
        within("li#work-#{work.id}") do
          expect(page).to have_selector ".work--title", text: "#{work.title}"
          expect(page).to have_selector ".concept", text: "#{work.concept}"
          expect(page).to have_link href: work_path(work)
        end
      end
    end
    within("li#work-#{current_work.id}") do
      click_link "#{current_work.title}"
    end
    expect(current_path).to eq work_path(current_work)
    within(".user--info__aside") do
      expect(page).to have_link href: user_path(current_work.user)
      expect(page).to have_selector "img[alt$='#{user.username}']"
      expect(page).to have_selector ".username", text: "#{current_work.user.username}"
    end
    within(".work--all__information") do
      within(".work--main_info") do
        expect(page).to have_selector "h3", text: "#{current_work.title}"
        expect(page).to have_selector "p", text: "#{current_work.concept}"
        expect(page).to have_selector "img[src$='#{current_work.image.filename}']"
        expect(page).to have_selector "p", text: "#{current_work.description}"
      end
      within(".work--sub_info") do
        current_work.illustrations.each do |illustration|
          within("li#illustration-#{illustration.id}") do
            expect(page).to have_selector "img[src$='#{illustration.photo.filename}']"
            expect(page).to have_selector ".name", text: "#{illustration.name}"
            expect(page).to have_selector ".description", text: "#{illustration.description}"
          end
        end
      end
    end
  end
end
