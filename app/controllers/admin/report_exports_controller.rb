# frozen_string_literal: true

module Admin
  # Legacy UI only. The SPA downloads through Api::V1::Admin::ReportExportsController.
  class ReportExportsController < BaseController
    def show
      authorize current_organization, :download_reports?

      report = ReportCatalog.find_permitted(params[:report].to_s, current_user, current_organization)

      unless report
        redirect_to root_path, alert: 'Access denied.' and return
      end

      if start_date > end_date
        flash[:alert] = 'Start date must be before end date'
        redirect_to admin_reports_path(start_date: params[:start_date], end_date: params[:end_date]) and return
      end

      filename = "#{current_organization.subdomain}-#{report.key}-#{start_date.strftime('%Y-%m-%d')}-#{end_date.strftime('%Y-%m-%d')}.csv"
      csv = report.generate(current_organization, start_date: start_date, end_date: end_date)

      if report.streamable?
        stream_csv(filename, csv)
      else
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

    def stream_csv(filename, lines)
      headers['X-Accel-Buffering'] = 'no'
      headers['Cache-Control'] = 'no-cache'
      headers['Content-Type'] = 'text/csv; charset=utf-8'
      headers['Content-Disposition'] = "attachment; filename=#{filename}"
      headers['Last-Modified'] = Time.zone.now.ctime.to_s
      headers.delete('Content-Length')

      self.response_body = lines
    end
  end
end
