# frozen_string_literal: true

require 'rails_helper'

describe Admin::FooterLinksController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, :admin, organization: organization) }

  let!(:link1) { FactoryBot.create(:footer_link, organization: organization) }
  let!(:link2) { FactoryBot.create(:footer_link, organization: organization) }
  let!(:other_org_link) { FactoryBot.create(:footer_link) }

  before do
    @request.host = "#{organization.subdomain}.test.host"
    sign_in user
  end

  describe 'GET #index' do
    before do
      get :index
    end

    it 'should assign correct links' do
      expect(assigns(:footer_links)).to contain_exactly(link1, link2)
    end

    it 'should not assign other org links' do
      expect(assigns(:footer_links)).not_to include(other_org_link)
    end
  end

  describe 'POST #create' do
    let(:link_params) { { label: 'Test Link', url: 'https://example.com' } }

    it 'should create a footer link' do
      expect do
        post :create, params: { footer_link: link_params }, format: :js
      end.to change { organization.footer_links.count }.by(1)
    end

    it 'should redirect to index if html request' do
      post :create, params: { footer_link: link_params }
      expect(response).to redirect_to admin_footer_links_path
    end
  end

  describe 'POST #delete' do
    it 'should delete footer link' do
      expect do
        delete :destroy, params: { id: link1.id }, format: :js
      end.to change { organization.footer_links.count }.by(-1)
    end

    it 'should not delete footer link from another organization' do
      expect do
        delete :destroy, params: { id: other_org_link.id }, format: :js
      end.not_to change(FooterLink, :count)
    end

    it 'should redirect to index with html request' do
      delete :destroy, params: { id: link1.id }
      expect(response).to redirect_to admin_footer_links_path
    end
  end
end
