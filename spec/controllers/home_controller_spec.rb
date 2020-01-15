# frozen_string_literal: true

require 'rails_helper'

describe HomeController do
  let(:org) { FactoryBot.create(:default_organization) }
  let(:category1) { FactoryBot.create(:category, organization: org) }
  let(:category2) { FactoryBot.create(:category, organization: org) }
  let(:disabled_category) { FactoryBot.create(:category, :disabled, organization: org) }

  let!(:category1_course) do
    FactoryBot.create(:course_with_lessons, organization: org, category: category1, display_on_dl: true, language: @english)
  end

  let!(:category2_course) do
    FactoryBot.create(:course_with_lessons, organization: org, category: category2, display_on_dl: true, language: @english)
  end

  let!(:disabled_category_course) do
    FactoryBot.create(:course_with_lessons, organization: org, category: disabled_category, display_on_dl: true, language: @english)
  end

  let!(:uncategorized_course) do
    FactoryBot.create(:course_with_lessons, organization: org, display_on_dl: true, language: @english)
  end

  before(:each) do
    @request.host = "#{org.subdomain}.test.host"
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    it 'responds successfully' do
      expect(response).to have_http_status(:success)
    end
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
