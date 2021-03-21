require 'rails_helper'

RSpec.describe "Works", type: :request do
  let(:base_title) { 'Atlier' }

  describe "GET /works/:id" do
    let(:user) { create(:user) }
    let(:work) { create(:work, user: user) }

    context "user not sign in" do
      before { get work_path work }

      it "redirect_to sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "user signed in" do
      before do
        sign_in user
        get work_path work
      end

      it "render show" do
        expect(response.status).to eq 200
      end

      it "has page title correctly" do
        expect(response.body).to match(/<title>#{work.title} | #{base_title}<\/title>/i)
      end
    end
  end

  describe "GET /works/new" do
    let(:user) { create(:user) }
    let(:title) { "新規投稿" }

    context "user not sign in" do
      before { get new_work_path }

      it "redirect_to sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "user signed in" do
      before do
        sign_in user
        get new_work_path
      end

      it "render new" do
        expect(response.status).to eq 200
      end

      it "has page title correctly" do
        expect(response.body).to match(/<title>#{title} | #{base_title}<\/title>/i)
      end
    end
  end

  describe "POST /works" do
    let(:user) { create(:user) }
    let(:work_create_form_params) { attributes_for(:work_create_form, current_user_id: user.id) }
    context "user doesnt sign in" do
      before do
        post works_path, params: {
          work_create_form: work_create_form_params,
        }
      end

      it "redirect to sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "user signed in" do
      before do
        sign_in user
        post works_path, params: {
          work_create_form: work_create_form_params,
        }
      end

      it "create success" do
        expect(response.status).to eq 200
      end
    end
  end

  describe "DELETE /works/id" do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let!(:work) { create(:work, user: user) }
    let!(:count) { Work.count }

    context "user doesnt sign in" do
      before do
        delete work_path work
      end

      it "redirect to sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "another user" do
      before do
        sign_in another_user
        delete work_path work
      end

      it "redirect to home page" do
        expect(response).to redirect_to root_path
      end
    end

    context "correct user sign in" do
      before do
        sign_in user
        delete work_path work
      end

      it "delete success" do
        expect(response.status).to eq 302
      end

      it "delete by work model" do
        expect(Work.count).to eq count - 1
      end
    end
  end
end
