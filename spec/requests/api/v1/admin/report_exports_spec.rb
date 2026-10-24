# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Admin::ReportExports', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, organization: organization) }
  let(:trainer) { create(:user, :trainer, organization: organization) }
  let(:valid_params) { { report: 'registrations', start_date: '2025-01-01', end_date: '2025-03-01' } }

  before { host! "#{organization.subdomain}.test.host" }

  def json
    JSON.parse(response.body)
  end

  def issue_url(user, params = valid_params)
    sign_in user
    post '/api/v1/admin/report_exports', params: params
    json['url']
  end

  describe 'POST /api/v1/admin/report_exports' do
    it 'returns a signed download url for an admin' do
      url = issue_url(admin)

      expect(response).to have_http_status(:ok)
      expect(url).to start_with('/api/v1/admin/report_exports/download?token=')
    end

    it 'returns a signed download url for a trainer' do
      issue_url(trainer)

      expect(response).to have_http_status(:ok)
    end

    it 'rejects guests' do
      post '/api/v1/admin/report_exports', params: valid_params

      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects regular users' do
      issue_url(create(:user, organization: organization))

      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects users from another organization' do
      other_admin = create(:user, :admin, organization: create(:organization, subdomain: 'other'))
      issue_url(other_admin)

      expect(response.status).to be_in([401, 403])
    end

    it 'rejects unknown reports' do
      issue_url(admin, valid_params.merge(report: 'not_a_report'))

      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects reports that do not apply to the organization' do
      issue_url(admin, valid_params.merge(report: 'completions_by_partner'))

      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects reports not permitted for the user role' do
      restricted = ReportCatalog::REPORTS.map do |report|
        report.key == 'registrations' ? report.dup.tap { |r| r.roles = %i[admin] } : report
      end
      stub_const('ReportCatalog::REPORTS', restricted)

      issue_url(trainer)

      expect(response).to have_http_status(:forbidden)
    end

    ['2025-1-1', '01/01/2025', '2025-02-30', 'yesterday', ''].each do |bad_date|
      it "rejects the malformed date #{bad_date.inspect}" do
        issue_url(admin, valid_params.merge(start_date: bad_date))

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it 'rejects a start date after the end date' do
      issue_url(admin, valid_params.merge(start_date: '2025-04-01'))

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['message']).to eq('Start date must be before end date.')
    end
  end

  describe 'GET /api/v1/admin/report_exports/download' do
    it 'streams the csv with safe download headers' do
      registered = create(:user, organization: organization, email: '=cmd@example.com', created_at: Date.new(2025, 2, 1))
      url = issue_url(trainer)

      get url

      expect(response).to have_http_status(:ok)
      expect(response.headers['Content-Type']).to eq('text/csv; charset=utf-8')
      expect(response.headers['Content-Disposition'])
        .to eq(%(attachment; filename="#{organization.subdomain}-registrations-2025-01-01-2025-03-01.csv"))
      expect(response.headers['Cache-Control']).to include('no-store')
      expect(response.body).to include("'#{registered.email}")
    end

    it 'generates non-streamed completion reports' do
      url = issue_url(admin, valid_params.merge(report: 'completions_by_survey_responses'))

      get url

      expect(response).to have_http_status(:ok)
      expect(response.headers['Content-Type']).to eq('text/csv; charset=utf-8')
    end

    it 'rejects a missing token' do
      sign_in admin
      get '/api/v1/admin/report_exports/download'

      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects a tampered token' do
      url = issue_url(admin)

      get "#{url}x"

      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects an expired token' do
      url = issue_url(admin)

      Timecop.travel(ReportExportToken::EXPIRES_IN.from_now + 1.second) do
        get url
      end

      expect(response).to have_http_status(:forbidden)
    end

    it "rejects another user's token" do
      url = issue_url(admin)

      sign_in trainer
      get url

      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects a token when signed out' do
      url = issue_url(admin)

      sign_out admin
      get url

      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects a token used on another organization' do
      other = create(:organization, subdomain: 'other')
      url = issue_url(admin)

      host! "#{other.subdomain}.test.host"
      get url

      expect(response.status).to be_in([401, 403])
    end

    it 'rejects a token after the user loses their role' do
      url = issue_url(trainer)

      trainer.remove_role(:trainer, organization)
      get url

      expect(response).to have_http_status(:forbidden)
    end
  end
end
