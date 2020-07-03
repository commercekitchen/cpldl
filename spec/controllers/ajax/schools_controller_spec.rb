# frozen_string_literal: true

require 'rails_helper'

describe Ajax::SchoolsController do
  let(:organization) { create(:organization, subdomain: 'npl') }

  before do
    @elementary_school = create(:school, school_type: :elementary, organization: organization)
    @middle_school = create(:school, school_type: :middle_school, organization: organization)
    @high_school = create(:school, school_type: :high_school, organization: organization)
    
    @request.host = 'npl.test.host'
  end

  describe 'GET #index' do
    it 'returns elementary schools' do
      get :index, params: { school_type: 'elementary' }, format: :js
      expect(response.body).to eq([@elementary_school].to_json)
    end

    it 'returns middle schools' do
      get :index, params: { school_type: 'middle_school' }, format: :js
      expect(response.body).to eq([@middle_school].to_json)
    end

    it 'returns high schools' do
      get :index, params: { school_type: 'high_school' }, format: :js
      expect(response.body).to eq([@high_school].to_json)
    end
  end
end
