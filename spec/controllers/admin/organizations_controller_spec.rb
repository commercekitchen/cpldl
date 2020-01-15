# frozen_string_literal: true

require 'rails_helper'

describe Admin::OrganizationsController do
  let(:www_org) { create(:default_organization) }
  let(:www_admin) { create(:user, :admin, organization: www_org) }
  let(:subsite_admin) { create(:user, :admin) }
  let(:org) { subsite_admin.organization }

  context 'as a DL admin' do
    before do
      @request.host = "#{www_org.subdomain}.test.host"
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
  end

  context 'as a subsite admin' do
    let(:org2) { create(:organization, subdomain: "#{org.subdomain}diff") }
    let(:update_params) { { branches: true } }

    before do
      @request.host = "#{org.subdomain}.test.host"
      sign_in subsite_admin
    end

    describe 'POST update' do
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
