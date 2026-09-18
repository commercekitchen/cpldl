# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CmsPages', type: :request do
  describe 'GET /api/v1/cms_pages/:id' do
    let(:organization) { create(:organization) }

    before do
      host! "#{organization.subdomain}.test.host"
    end

    it 'returns the page when published' do
      cms_page = create(:cms_page, organization: organization, pub_status: 'P')

      get "/api/v1/cms_pages/#{cms_page.friendly_id}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['slug']).to eq(cms_page.slug)
    end

    it 'returns a 404 when the page is archived' do
      cms_page = create(:cms_page, organization: organization, pub_status: 'A')

      get "/api/v1/cms_pages/#{cms_page.friendly_id}"

      expect(response).to have_http_status(:not_found)
    end
  end
end
