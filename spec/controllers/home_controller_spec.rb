# frozen_string_literal: true

require 'rails_helper'

describe HomeController do
  let(:org) { FactoryBot.create(:default_organization) }

  before(:each) do
    @request.host = "#{org.subdomain}.test.host"
  end

  describe 'GET #home_language_toggle' do
    it 'should set session locale to valid language' do
      get :language_toggle, params: { lang: 'es' }
      expect(controller.session[:locale]).to eq('es')
    end

    it 'should not set session locale to invalid language' do
      get :language_toggle, params: { lang: 'es UNION ALL SELECT NULL#' }
      expect(controller.session[:locale]).to be_nil
    end
  end

end
