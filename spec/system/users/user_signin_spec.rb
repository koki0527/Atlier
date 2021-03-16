require 'rails_helper'

RSpec.describe 'User signin', type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:user) { create(:user) }

  context "user has valid signin imformation" do
    it "signin success" do
      visit root_path
      click_link "ログイン"
      expect(page).to have_selector "h2", text: "ログイン"
      within("form") do
        fill_in "Eメール", with: user.email
        fill_in "パスワード", with: user.password
        click_button "ログイン"
      end
      expect(current_path).to eq root_path
      expect(page).to have_selector ".notice", text: "ログインしました。"
      visit current_path
      expect(page).not_to have_selector ".notice"
    end
  end

  context "user has invalid signin imformation" do
    let(:invalid_password) { "abcd1234" }
    it "signin false" do
      visit root_path
      click_link "ログイン"
      expect(page).to have_selector "h2", text: "ログイン"
      within("form") do
        fill_in "Eメール", with: user.email
        fill_in "パスワード", with: invalid_password
        click_button "ログイン"
      end
      expect(current_path).to eq new_user_session_path
      expect(page).to have_selector ".alert", text: "Eメールまたはパスワードが違います。"
      visit current_path
      expect(page).not_to have_selector ".alert"
    end
  end
end