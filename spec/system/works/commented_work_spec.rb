require "rails_helper"

RSpec.describe "Commented work", type: :system, js: true do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:work) { create(:work, user: user) }
  let!(:comment_by_another) { create(:comment, user: another_user, work: work) }
  let(:content) { "This is the comment" }
  let(:current_comment) { Comment.find_by(user_id: user.id, content: content) }

  it "display and create, destroy comment" do
    sign_in user
    visit work_path work
    within(".comments_to_work__aside") do
      within("li#comment-#{comment_by_another.id}") do
        expect(page).to have_selector ".username", text: "#{comment_by_another.user.username}"
        expect(page).to have_selector ".content", text: "#{comment_by_another.content}"
        expect(page).not_to have_selector ".delete"
      end
      within(".form--comment") do
        fill_in "comment[content]", with: content
        click_button "commit"
      end
    end
    expect(page).to have_selector "p.success"
    within(".comments_to_work__aside") do
      within("li#comment-#{current_comment.id}") do
        expect(page).to have_selector ".username", text: "#{user.username}"
        expect(page).to have_selector ".content", text: "#{content}"
        expect(page).to have_link href: comment_path(current_comment)
      end
    end
    visit current_path
    expect(page).not_to have_selector "p.success"
    within(".comments_to_work__aside") do
      within("li#comment-#{current_comment.id}") do
        page.accept_confirm do
          click_on "削除"
        end
      end
    end
    expect(page).to have_selector "p.success"
    within(".comments_to_work__aside") do
      within("ol.comments") do
        expect(page).not_to have_selector "li#comment-#{current_comment.id}"
      end
    end
    visit current_path
    expect(page).not_to have_selector "p.success"
  end
end
