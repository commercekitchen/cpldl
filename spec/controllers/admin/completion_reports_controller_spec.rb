# frozen_string_literal: true

require 'rails_helper'

describe Admin::CompletionReportsController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

  before do
    @request.host = "#{organization.subdomain}.test.host"
    sign_in admin
  end

  describe '#completions' do
    it 'redirects http requests' do
      get :show, params: { group_by: 'zip_code' }
      expect(response).to redirect_to(admin_dashboard_index_path)
    end

    it 'responds with a csv' do
      get :show, params: { format: 'csv', group_by: 'zip_code' }
      expect(response.header['Content-Type']).to include('text/csv')
    end

    it 'calls completion report service with correct group_by argument' do
      expect_any_instance_of(CompletionReportService).to receive(:generate_completion_report).with(group_by: 'zip_code')
      get :show, params: { format: 'csv', group_by: 'zip_code' }
    end
  end
end
