module Admin
  class ReportExportsController < BaseController

    def show
      csv = run_exporter(params[:report])
      respond_to do |format|
        format.csv { send_data csv, filename: params[:report] }
      end
    end

    private

    def run_exporter(exporter)
      case exporter
      when "registrations"
        RegistrationExporter.new(current_organization).to_csv
      when "completed_courses"
        CompletedCoursesExporter.new(current_organization).to_csv
      when "incomplete_courses"
        UnfinishedCoursesExporter.new(current_organization).to_csv
      when "no_courses"
        NoCoursesReportExporter.new(current_organization).to_csv
      end
    end

  end
end
