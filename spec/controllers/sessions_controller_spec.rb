# frozen_string_literal: true

require 'rails_helper'

describe SessionsController do

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    create(:default_organization)
    @request.host = 'www.test.host'
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    context 'library card org' do
      let(:library_card_org) { FactoryBot.create(:organization, :library_card_login) }
  
      it 'assigns library_card_login variable' do
        @request.host = "#{library_card_org.subdomain}.test.host"
        get :new
        expect(assigns(:library_card_login)).to eq(true)
      end
    end
  end

  describe 'POST #create' do
    context 'phone number login' do
      let(:org) { FactoryBot.create(:organization, subdomain: 'getconnected', phone_number_users_enabled: true) }

      it 'assigns user role' do
        @request.host = "#{org.subdomain}.test.host"
        expect do
          post :create, params: { phone_number: { phone: '1231231234' } }
        end.to change { User.with_role(:user, org).count }.by(1)
      end
    end
  end

end
