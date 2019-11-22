require 'rails_helper'

describe Admin::PartnersController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, :admin, organization: organization) }

  let!(:partner1) { FactoryBot.create(:partner, organization: organization) }
  let!(:partner2) { FactoryBot.create(:partner, organization: organization) }
  let!(:other_org_partner) { FactoryBot.create(:partner) }

  before do
    @request.host = "#{organization.subdomain}.test.host"
    sign_in user
  end

  describe 'GET #index' do
    before do
      get :index
    end

    it 'should assign partners' do
      expect(assigns(:partners)).to include(partner1, partner2)
    end

    it 'should not assign other org partners' do
      expect(assigns(:partners)).to_not include(other_org_partner)
    end
  end

  describe 'POST #create' do
    let(:partner_params) { { name: 'Test Partner' } }

    it 'should create a partner' do
      expect do
        post :create, params: { partner: partner_params }, format: :js
      end.to change(Partner, :count).by(1)
    end

    it 'should redirect to index if html request' do
      post :create, params: { partner: partner_params }
      expect(response).to redirect_to admin_partners_path
    end
  end

  describe 'POST #delete' do
    it 'should delete partner' do
      expect do
        delete :destroy, params: { id: partner1.id }, format: :js
      end.to change(Partner, :count).by(-1)
    end

    it 'should not delete partner from another organization' do
      expect do
        delete :destroy, params: { id: other_org_partner.id }, format: :js
      end.to_not change(Partner, :count)
    end

    it 'should redirect to index if html request' do
      delete :destroy, params: { id: partner1.id }
      expect(response).to redirect_to admin_partners_path
    end
  end
end
