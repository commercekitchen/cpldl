# frozen_string_literal: true

module Admin
  class ReportExportsController < BaseController

    def show
      authorize current_organization, :download_reports?
      csv = run_exporter(params[:report])
      timestamp = Time.zone.now.strftime('%Y-%m-%d')
      filename = "#{current_organization.subdomain}-#{params[:report]}-#{timestamp}"
      respond_to do |format|
        format.csv { send_data csv, filename: "#{filename}.csv" }
      end
    end

    private

    def run_exporter(exporter)
      case exporter
      when 'registrations'
        RegistrationExporter.new(current_organization).to_csv
      when 'completed_courses'
        CompletedCoursesExporter.new(current_organization).to_csv
      when 'completed_lessons'
        CompletedLessonsExporter.new(current_organization).to_csv
      when 'incomplete_courses'
        UnfinishedCoursesExporter.new(current_organization).to_csv
      when 'no_courses'
        NoCoursesReportExporter.new(current_organization).to_csv
      end
    end

  end
end
