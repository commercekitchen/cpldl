require 'rails_helper'

describe Admin::PagesController do
  let(:org) { create(:default_organization) }
  let(:user) { create(:user, organization: org) }
  let(:admin) { create(:user, :admin, organization: org) }

  before do
    switch_to_subdomain(org.subdomain)
    sign_in admin
  end

  describe 'get#index' do
    let(:page1) { create(:cms_page, title: 'Page 1', organization: org) }
    let(:page2) { create(:cms_page, title: 'Page 2', organization: org) }
    let(:page3) { create(:cms_page, title: 'Page 3', organization: org) }

    it 'should have a successful response' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns all cms_pages to @cms_pages' do
      get :index
      expect(assigns(:cms_pages)).to contain_exactly(page1, page2, page3)
    end
  end
end
