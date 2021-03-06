require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  let(:base_title) { 'Atlier' }

  describe "GET /" do
    before { get root_url }

    it "render home" do
      expect(response.status).to eq 200
    end

    it 'have page_title of title tag' do
      expect(response.body).to match(/<title>#{base_title}<\/title>/i)
    end
  end

  describe "GET /contact" do
    let(:page_title) { 'お問い合わせ' }

    before { get contact_url }

    it "render contact" do
      expect(response.status).to eq 200
    end

    it 'have page_title of title tag' do
      expect(response.body).to match(/<title>#{page_title} - #{base_title}<\/title>/i)
    end
  end

  describe "GET /tos" do
    let(:page_title) { '利用規約' }

    before { get terms_url }

    it "render terms" do
      expect(response.status).to eq 200
    end

    it 'have page_title of title tag' do
      expect(response.body).to match(/<title>#{page_title} - #{base_title}<\/title>/i)
    end
  end
end
