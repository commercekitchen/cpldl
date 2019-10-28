require 'rails_helper'

describe Admin::OrganizationsController do
  let(:www_org) { create(:default_organization) }
  let(:www_admin) { create(:user, :admin, organization: www_org) }
  let(:subsite_admin) { create(:user, :admin) }
  let(:org) { subsite_admin.organization }

  context 'as a DL admin' do
    before do
      switch_to_subdomain(www_org.subdomain)
      sign_in www_admin
    end

    describe 'GET index' do
      let(:org1) { create(:organization) }
      let(:org2) { create(:organization) }
      let(:org3) { create(:organization) }
      
      it 'should have a successful response' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'should assign all organizations' do
        get :index
        expect(assigns(:organizations)).to contain_exactly(www_org, org, org1, org2, org3)
      end
    end

    describe 'GET new' do
      it 'should return a success' do
        get :new
        expect(response).to have_http_status(:success)
      end

      it 'should build an organization' do
        get :new
        expect(assigns(:organization)).to be_a_new(Organization)
      end
    end

    describe 'POST create' do
      let(:valid_org_params) do
        { name: 'New Org', subdomain: 'no', branches: false, accepts_programs: false }
      end
      let(:invalid_org_params) { valid_org_params.merge(name: nil) }

      context 'valid attributes' do
        it 'should redirect to organizations index' do
          post :create, params: { organization: valid_org_params }
          expect(response).to redirect_to(admin_organizations_path)
        end
      end

      context 'invalid attributes' do
        it 'should return error' do
          post :create, params: { organization: invalid_org_params }
          expect(assigns[:organization].errors.full_messages).to include("Name can't be blank")
        end
      end
    end
  end

  context 'as a subsite admin' do
    let(:org2) { create(:organization) }
    let(:update_params) { { branches: true } }

    before do
      switch_to_subdomain(org.subdomain)
      sign_in subsite_admin
    end

    describe 'POST update' do
      before do
        request.host = "#{org.subdomain}.example.com"
      end

      it 'should return ok for correct subsite' do
        patch :update, params: { id: org.id, organization: update_params, format: :json }
        expect(response).to have_http_status(:ok)
      end

      it 'should return forbidden status for another subsite' do
        patch :update, params: { id: org2.id, organization: update_params, format: :json }
        expect(response).to have_http_status(:forbidden)
      end

      it 'should update branches setting' do
        patch :update, params: { id: org.id, organization: update_params, format: :json }
        expect(org.reload.branches).to be_truthy
      end
    end
  end

end
