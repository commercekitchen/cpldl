# frozen_string_literal: true

require 'rails_helper'

describe Ajax::SchoolsController do
  let(:organization) { create(:organization, subdomain: 'npl') }

  before do
    @elementary_school1 = create(:school, school_type: :elementary, organization: organization)
    @elementary_school2 = create(:school, school_type: :elementary, organization: organization)
    @middle_school = create(:school, school_type: :middle_school, organization: organization)
    @high_school = create(:school, school_type: :high_school, organization: organization)

    create(:school, school_type: :elementary, organization: organization, enabled: false)
    create(:school, school_type: :elementary, organization: organization, enabled: false)
    create(:school, school_type: :middle_school, organization: organization, enabled: false)
    create(:school, school_type: :high_school, organization: organization, enabled: false)

    @request.host = "#{organization.subdomain}.test.host"
  end

  describe 'GET #index' do
    it 'returns active elementary schools' do
      get :index, params: { school_type: 'elementary' }, format: :js
      expect(JSON.parse(response.body)).to contain_exactly(JSON.parse(@elementary_school1.to_json), JSON.parse(@elementary_school2.to_json))
    end

    it 'returns active middle schools' do
      get :index, params: { school_type: 'middle_school' }, format: :js
      expect(response.body).to eq([@middle_school].to_json)
    end

    it 'returns active high schools' do
      get :index, params: { school_type: 'high_school' }, format: :js
      expect(response.body).to eq([@high_school].to_json)
    end
  end
end
