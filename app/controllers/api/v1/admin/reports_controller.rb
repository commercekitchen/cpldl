# frozen_string_literal: true

module Api
  module V1
    module Admin
      class ReportsController < ::Api::V1::BaseController
        def index
          authorize current_organization, :download_reports?
          render json: { reports: available_reports, analyticsDashboardUrl: current_organization.looker_studio_dashboard_url }
        end

        private

        def available_reports
          ReportCatalog.available_for(current_user, current_organization).map do |report|
            { key: report.key, title: report.title }
          end
        end
      end
    end
  end
end
