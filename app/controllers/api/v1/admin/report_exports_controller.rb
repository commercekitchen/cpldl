# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Two-step report download; see ReportExportToken for the rationale.
      #
      #   POST /api/v1/admin/report_exports           -> { url: ".../download?token=..." }
      #   GET  /api/v1/admin/report_exports/download  -> streamed CSV
      #
      # Authorization is checked on both steps, so revoking a role takes
      # effect even for a token that has already been issued.
      class ReportExportsController < ::Api::V1::BaseController
        DATE_FORMAT = /\A\d{4}-\d{2}-\d{2}\z/.freeze
        INVALID_LINK_MESSAGE = 'This download link is invalid or has expired.'

        before_action :require_user

        def create
          authorize current_organization, :download_reports?

          report = ReportCatalog.find_permitted(params[:report].to_s, current_user, current_organization)
          return render_error(:forbidden, 'You are not authorized to download this report.') unless report

          start_date = parse_date(params[:start_date])
          end_date = parse_date(params[:end_date])
          return render_error(:unprocessable_entity, 'Start and end dates must be valid dates.') unless start_date && end_date
          return render_error(:unprocessable_entity, 'Start date must be before end date.') if start_date > end_date

          token = ReportExportToken.generate(
            user: current_user, organization: current_organization,
            report_key: report.key, start_date: start_date, end_date: end_date
          )
          render json: { url: download_api_v1_admin_report_exports_path(token: token) }
        end

        def download
          payload = ReportExportToken.verify(params[:token])
          return render_error(:forbidden, INVALID_LINK_MESSAGE) unless token_matches_request?(payload)

          authorize current_organization, :download_reports?

          report = ReportCatalog.find_permitted(payload.report_key, current_user, current_organization)
          return render_error(:forbidden, INVALID_LINK_MESSAGE) unless report

          apply_download_headers(filename(report, payload))
          csv = report.generate(current_organization, start_date: payload.start_date, end_date: payload.end_date)

          if report.streamable?
            # Streamed so large reports start downloading immediately instead
            # of timing out while the whole file is built.
            headers['X-Accel-Buffering'] = 'no'
            headers['Last-Modified'] = Time.zone.now.httpdate
            headers.delete('Content-Length')
            self.response_body = csv
          else
            self.response_body = [csv]
          end
        end

        private

        def require_user
          render_error(:unauthorized, 'Not authenticated.') unless current_user
        end

        def token_matches_request?(payload)
          payload.present? &&
            payload.user_id == current_user.id &&
            payload.organization_id == current_organization.id
        end

        def parse_date(value)
          return nil unless value.is_a?(String) && value.match?(DATE_FORMAT)

          Date.iso8601(value)
        rescue ArgumentError
          nil
        end

        def filename(report, payload)
          subdomain = current_organization.subdomain.to_s.gsub(/[^a-z0-9-]/i, '')
          "#{subdomain}-#{report.key}-#{payload.start_date.iso8601}-#{payload.end_date.iso8601}.csv"
        end

        def apply_download_headers(filename)
          headers['Content-Type'] = 'text/csv; charset=utf-8'
          headers['Content-Disposition'] = %(attachment; filename="#{filename}")
          headers['Cache-Control'] = 'no-cache, no-store'
          headers['X-Content-Type-Options'] = 'nosniff'
        end

        def render_error(status, message)
          render status: status, json: { message: message }
        end
      end
    end
  end
end
