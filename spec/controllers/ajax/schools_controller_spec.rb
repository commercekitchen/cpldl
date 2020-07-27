# frozen_string_literal: true

require 'rails_helper'

describe Ajax::SchoolsController do
  let(:organization) { create(:organization, subdomain: 'npl') }

  before do
    @elementary_school1 = create(:school, school_type: :elementary, organization: organization)
    @elementary_school2 = create(:school, school_type: :elementary, organization: organization)
    @middle_school = create(:school, school_type: :middle, organization: organization)
    @high_school = create(:school, school_type: :high, organization: organization)
    @charter_school = create(:school, school_type: :charter, organization: organization)
    @specialty_school = create(:school, school_type: :specialty, organization: organization)

    create(:school, school_type: :elementary, organization: organization, enabled: false)
    create(:school, school_type: :elementary, organization: organization, enabled: false)
    create(:school, school_type: :middle, organization: organization, enabled: false)
    create(:school, school_type: :high, organization: organization, enabled: false)
    create(:school, school_type: :charter, organization: organization, enabled: false)
    create(:school, school_type: :specialty, organization: organization, enabled: false)

    @request.host = "#{organization.subdomain}.test.host"
  end

  describe 'GET #index' do
    it 'returns active elementary schools' do
      get :index, params: { school_type: 'elementary' }, format: :js
      expect(JSON.parse(response.body)).to contain_exactly(JSON.parse(@elementary_school1.to_json), JSON.parse(@elementary_school2.to_json))
    end

    it 'returns active middle schools' do
      get :index, params: { school_type: 'middle' }, format: :js
      expect(response.body).to eq([@middle_school].to_json)
    end

    it 'returns active high schools' do
      get :index, params: { school_type: 'high' }, format: :js
      expect(response.body).to eq([@high_school].to_json)
    end

    it 'returns active charter schools' do
      get :index, params: { school_type: 'charter' }, format: :js
      expect(response.body).to eq([@charter_school].to_json)
    end

    it 'returns active specialty schools' do
      get :index, params: { school_type: 'specialty' }, format: :js
      expect(response.body).to eq([@specialty_school].to_json)
    end
  end
end
