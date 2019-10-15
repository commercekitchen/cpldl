# frozen_string_literal: true

require 'rails_helper'

describe SessionsController do

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    create(:default_organization)
    @request.host = 'www.test.host'
    @english = create(:language)
    @spanish = create(:spanish_lang)
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'library card org' do
    let(:library_card_org) { FactoryBot.create(:organization, :library_card_login) }

    it 'assigns library_card_login variable' do
      @request.host = "#{library_card_org.subdomain}.test.host"
      get :new
      expect(assigns(:library_card_login)).to eq(true)
    end
  end

end
