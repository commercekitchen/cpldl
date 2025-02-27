# frozen_string_literal: true

module Admin
  class ReportExportsController < BaseController
    def show
      authorize current_organization, :download_reports?

      if start_date > end_date
        flash[:alert] = 'Start date must be before end date'
        redirect_to admin_reports_path(start_date: params[:start_date], end_date: params[:end_date]) and return
      end

      csv = generate_report(params[:report])
      filename = "#{current_organization.subdomain}-#{params[:report]}-#{start_date.strftime('%Y-%m-%d')}-#{end_date.strftime('%Y-%m-%d')}"
      respond_to do |format|
        format.csv { send_data csv, filename: "#{filename}.csv", type: 'text/csv; header=present' }
      end
    end

    private

    def start_date
      if params[:start_date]
        Date.parse(params[:start_date])
      else
        1.month.ago.beginning_of_month
      end
    end

    def end_date
      if params[:end_date]
        Date.parse(params[:end_date])
      else
        1.month.ago.end_of_month
      end
    end

    def generate_report(exporter)
      case exporter
      when 'registrations'
        RegistrationExporter.new(current_organization, start_date: start_date, end_date: end_date).to_csv
      when 'completed_courses'
        CompletedCoursesExporter.new(current_organization, start_date: start_date, end_date: end_date).to_csv
      when 'completed_lessons'
        CompletedLessonsExporter.new(current_organization, start_date: start_date, end_date: end_date).to_csv
      when 'incomplete_courses'
        UnfinishedCoursesExporter.new(current_organization, start_date: start_date, end_date: end_date).to_csv
      when 'no_courses'
        NoCoursesReportExporter.new(current_organization, start_date: start_date, end_date: end_date).to_csv
      when 'completions_by_library'
        completion_report_service.generate_completion_report(group_by: 'library', start_date: start_date, end_date: end_date)
      when 'completions_by_zip_code'
        completion_report_service.generate_completion_report(group_by: 'zip_code', start_date: start_date, end_date: end_date)
      when 'completions_by_partner'
        completion_report_service.generate_completion_report(group_by: 'partner', start_date: start_date, end_date: end_date)
      when 'completions_by_survey_responses'
        completion_report_service.generate_completion_report(group_by: 'survey_responses', start_date: start_date, end_date: end_date)
      else
        raise "Unknown report type: #{report_type}"
      end
    end

    def completion_report_service
      @completion_report_service ||= CompletionReportService.new(organization: current_organization)
    end
  end
end
