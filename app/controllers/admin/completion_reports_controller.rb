# frozen_string_literal: true

module Admin
  class CompletionReportsController < BaseController

    def show
      @report_service = CompletionReportService.new(organization: current_organization)

      respond_to do |format|
        format.html { redirect_to admin_dashboard_index_path }
        format.csv { send_data @report_service.generate_completion_report(group_by: params[:group_by]), type: 'text/csv; header=present' }
      end
    end
  end
end
