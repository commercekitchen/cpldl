# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Reports', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:organization) { create(:organization, trainer_reports_enabled: true) }

  before { host! "#{organization.subdomain}.test.host" }

  def json
    JSON.parse(response.body)
  end

  it 'lists reports for an admin' do
    sign_in create(:user, :admin, organization: organization)

    get '/api/v1/admin/reports'

    expect(response).to have_http_status(:ok)
    expect(json['reports'].map { |r| r['key'] }).to include('registrations', 'completed_courses')
  end

  it 'lists reports for a trainer' do
    sign_in create(:user, :trainer, organization: organization)

    get '/api/v1/admin/reports'

    expect(response).to have_http_status(:ok)
    expect(json['reports'].map { |r| r['key'] }).to include('registrations', 'completed_courses')
  end

  it 'forbids trainers when the organization has not opted in' do
    organization.update!(trainer_reports_enabled: false)
    sign_in create(:user, :trainer, organization: organization)

    get '/api/v1/admin/reports'

    expect(response).to have_http_status(:forbidden)
  end

  it 'only lists reports permitted for the user role' do
    admin_only = ReportCatalog::Report.new(key: 'admin_only', title: 'Admin Only', roles: %i[admin])
    stub_const('ReportCatalog::REPORTS', ReportCatalog::REPORTS + [admin_only])

    sign_in create(:user, :trainer, organization: organization)
    get '/api/v1/admin/reports'
    expect(json['reports'].map { |r| r['key'] }).not_to include('admin_only')

    sign_in create(:user, :admin, organization: organization)
    get '/api/v1/admin/reports'
    expect(json['reports'].map { |r| r['key'] }).to include('admin_only')
  end

  it 'forbids regular users' do
    sign_in create(:user, organization: organization)

    get '/api/v1/admin/reports'

    expect(response).to have_http_status(:forbidden)
  end

  it 'forbids guests' do
    get '/api/v1/admin/reports'

    expect(response).to have_http_status(:forbidden)
  end
end
