# frozen_string_literal: true

module Api
  module V1
    module Admin
      class SettingsController < ::Api::V1::BaseController
        before_action :require_admin

        def show
          render json: settings_payload
        end

        def update
          org_attrs = {}
          org_attrs.merge!(general_params.to_h) if params[:general].present?
          org_attrs.merge!(survey_org_params.to_h) if params[:survey].present?
          org_attrs.merge!(theme_params.to_h) if params[:theme].present?
          org_attrs.merge!(custom_text_params.to_h) if params[:custom_text].present?
          org_attrs.merge!(analytics_params.to_h) if params[:analytics].present?

          if org_attrs.present? && !current_organization.update(org_attrs)
            render status: :unprocessable_entity, json: { errors: current_organization.errors.full_messages }
            return
          end

          if params[:survey].present?
            update_translation('en', params[:survey][:enButtonText].to_s)
            update_translation('es', params[:survey][:esButtonText].to_s)
          end

          render json: settings_payload
        end

        def footer_logo
          file = params[:footer_logo_file]
          unless file
            render status: :unprocessable_entity, json: { errors: ['No file provided'] }
            return
          end

          current_organization.footer_logo_file.attach(file)
          if current_organization.save
            render json: { footerLogoUrl: footer_logo_url }
          else
            render status: :unprocessable_entity, json: { errors: current_organization.errors.full_messages }
          end
        end

        def header_logo
          file = params[:header_logo_file]
          unless file
            render status: :unprocessable_entity, json: { errors: ['No file provided'] }
            return
          end

          current_organization.logo.attach(file)
          if current_organization.save
            render json: { logoUrl: logo_url }
          else
            render status: :unprocessable_entity, json: { errors: current_organization.errors.full_messages }
          end
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def general_params
          params.require(:general).permit(:footer_logo_link, :login_required, :branches)
        end

        def theme_params
          params.require(:theme).permit(:primary_color, :secondary_color)
        end

        def survey_org_params
          params.require(:survey).permit(:user_survey_enabled, :user_survey_link, :spanish_survey_link)
        end

        def custom_text_params
          params.require(:custom_text).permit(:home_header_en, :home_subheader_en, :home_header_es, :home_subheader_es)
        end

        def analytics_params
          params.require(:analytics).permit(:looker_studio_dashboard_url)
        end

        def update_translation(locale, value)
          key = "course_completion_page.#{current_organization.subdomain}.user_survey_button_text"
          translation = Translation.find_or_initialize_by(locale: locale, key: key)
          translation.update(value: value)
        end

        def survey_button_text(locale)
          key = "course_completion_page.#{current_organization.subdomain}.user_survey_button_text"
          Translation.find_by(locale: locale, key: key)&.value
        end

        def footer_logo_url
          return nil unless current_organization.footer_logo_file.attached?

          rails_blob_path(current_organization.footer_logo_file, only_path: true)
        end

        def logo_url
          return nil unless current_organization.logo.attached?

          rails_blob_path(current_organization.logo, only_path: true)
        end

        def settings_payload
          {
            isMainSite: current_organization.main_site?,
            general: {
              logoUrl: logo_url,
              footerLogoUrl: footer_logo_url,
              footerLogoLink: current_organization.footer_logo_link,
              loginRequired: current_organization.login_required
            },
            theme: {
              primaryColor: current_organization.primary_color.presence || DefaultTheme::PRIMARY_COLOR,
              secondaryColor: current_organization.secondary_color.presence || DefaultTheme::SECONDARY_COLOR
            },
            footerLinks: footer_links_payload,
            survey: {
              userSurveyEnabled: current_organization.user_survey_enabled,
              userSurveyLink: current_organization.user_survey_link,
              spanishSurveyLink: current_organization.spanish_survey_link,
              enButtonText: survey_button_text('en'),
              esButtonText: survey_button_text('es')
            },
            branches: {
              enabled: current_organization.branches || false,
              locations: library_locations_payload
            },
            customText: {
              homeHeaderEn: current_organization.home_header_en,
              homeSubheaderEn: current_organization.home_subheader_en,
              homeHeaderEs: current_organization.home_header_es,
              homeSubheaderEs: current_organization.home_subheader_es
            },
            analytics: {
              lookerStudioDashboardUrl: current_organization.looker_studio_dashboard_url
            },
            languages: Language.order(:name).map { |l| { id: l.id, name: l.name } }
          }
        end

        def library_locations_payload
          current_organization.library_locations.map do |loc|
            { id: loc.id, name: loc.name, zipcode: loc.zipcode, sortOrder: loc.sort_order }
          end
        end

        def footer_links_payload
          current_organization.footer_links.includes(:language).order(:created_at).map do |link|
            { id: link.id, label: link.label, url: link.url, languageId: link.language_id, languageName: link.language&.name }
          end
        end
      end
    end
  end
end
