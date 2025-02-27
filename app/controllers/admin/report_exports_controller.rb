# frozen_string_literal: true

module Admin
  class ReportExportsController < BaseController
    def show
      authorize current_organization, :download_reports?

      if start_date > end_date
        flash[:alert] = 'Start date must be before end date'
        redirect_to admin_reports_path(start_date: params[:start_date], end_date: params[:end_date]) and return
      end

      @report_type = params[:report]

      filename = "#{current_organization.subdomain}-#{@report_type}-#{start_date.strftime('%Y-%m-%d')}-#{end_date.strftime('%Y-%m-%d')}.csv"

      if streamable_report?
        stream_csv(filename) do |yielder|
          puts "inside of stream_csv block"
          exporter.stream_csv.each { |row| yielder << row }
        end
      else
        csv = generate_completion_report
        send_data csv, filename: filename, type: 'text/csv; header=present'
      end
    end

    private

    def start_date
      @start_date ||= if params[:start_date]
        Date.parse(params[:start_date])
      else
        1.month.ago.beginning_of_month
      end
    end

    def end_date
      @end_date ||= if params[:end_date]
        Date.parse(params[:end_date])
      else
        1.month.ago.end_of_month
      end
    end

    def streamable_report?
      ['registrations', 'completed_courses', 'completed_lessons', 'incomplete_courses', 'no_courses'].include? @report_type
    end

    def exporter
      case @report_type
      when 'registrations'
        RegistrationExporter.new(current_organization, start_date: start_date, end_date: end_date)
      when 'completed_courses'
        CompletedCoursesExporter.new(current_organization, start_date: start_date, end_date: end_date)
      when 'completed_lessons'
        CompletedLessonsExporter.new(current_organization, start_date: start_date, end_date: end_date)
      when 'incomplete_courses'
        UnfinishedCoursesExporter.new(current_organization, start_date: start_date, end_date: end_date)
      when 'no_courses'
        NoCoursesReportExporter.new(current_organization, start_date: start_date, end_date: end_date)
      end
    end

    def generate_completion_report
      case @report_type
      when 'completions_by_library'
        completion_report_service.generate_completion_report(group_by: 'library', start_date: start_date, end_date: end_date)
      when 'completions_by_zip_code'
        completion_report_service.generate_completion_report(group_by: 'zip_code', start_date: start_date, end_date: end_date)
      when 'completions_by_partner'
        completion_report_service.generate_completion_report(group_by: 'partner', start_date: start_date, end_date: end_date)
      when 'completions_by_survey_responses'
        completion_report_service.generate_completion_report(group_by: 'survey_responses', start_date: start_date, end_date: end_date)
      end
    end

    def completion_report_service
      @completion_report_service ||= CompletionReportService.new(organization: current_organization)
    end

    def stream_csv(filename)
      puts "streaming csv"
      headers['Content-Type'] = 'text/csv; header=present'
      headers['Content-Disposition'] = "attachment; filename=#{filename}"
      headers['Cache-Control'] = 'no-cache'

      self.response_body = Enumerator.new do |yielder|
        puts "inside of Enumerator"
        yield yielder
      end
      puts "after enumerator"
    end
  end
end
