# frozen_string_literal: true

module Api
  module V1
    module Admin
      class ReportsController < ::Api::V1::BaseController
        before_action :require_admin

        def index
          skip_authorization
          render json: { reports: available_reports, analyticsLinks: analytics_links }
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def analytics_links
          links = []
          subdomain = current_organization.subdomain

          if I18n.exists?("google_analytics_url.#{subdomain}")
            links << { title: 'Google Analytics Dashboard', url: I18n.t("google_analytics_url.#{subdomain}") }
          end

          if I18n.exists?("google_studio_url.#{subdomain}")
            links << { title: 'Google Analytics Report', url: I18n.t("google_studio_url.#{subdomain}") }
          end

          links
        end

        def available_reports
          reports = []

          if current_organization.branches?
            reports << { key: 'completions_by_library', title: 'Completions Report (by Library)' }
            reports << { key: 'completions_by_zip_code', title: 'Completions Report (by Zip Code)' }
          end

          if current_organization.accepts_partners?
            reports << { key: 'completions_by_partner', title: 'Completions Report (by Partner)' }
          end

          reports << { key: 'completions_by_survey_responses', title: 'Completions Report (by Survey Answers)' }
          reports << { key: 'incomplete_courses', title: 'Incomplete Courses' }
          reports << { key: 'completed_courses', title: 'Completed Courses' }
          reports << { key: 'completed_lessons', title: 'Completed Lessons' }
          reports << { key: 'no_courses', title: 'Users that have not started a course' }
          reports << { key: 'registrations', title: 'All Registrations' }

          reports
        end
      end
    end
  end
end
