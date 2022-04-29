# frozen_string_literal: true

module Admin
  module Custom
    class UserSurveysController < Admin::Custom::BaseController
      before_action :load_translations

      def show; end

      def update
        if @organization.update(org_params) & update_translations
          flash[:info] = 'Organization user survey updated.'
          I18n.backend.reload!
          redirect_to admin_custom_user_surveys_path
        else
          flash[:error] = @organization.invalid? ? @organization.errors.full_messages : @translation_errors.flatten
          render :show
        end
      end

      private

      def load_translations
        key = "course_completion_page.#{current_organization.subdomain}.user_survey_button_text"
        @en_translation = Translation.find_or_initialize_by(locale: 'en', key: key)
        @es_translation = Translation.find_or_initialize_by(locale: 'es', key: key)
      end

      def org_params
        params.require(:organization).permit(:user_survey_link,
                                             :spanish_survey_link,
                                             :user_survey_button_text,
                                             :user_survey_enabled)
      end

      def update_translations
        @translation_errors = []
        params.require(:translation).permit!.each do |_locale, values|
          translation = Translation.find_or_initialize_by(key: values[:key], locale: values[:locale])

          unless translation.update(values.except(:id))
            @translation_errors << translation.errors.full_messages
            return false
          end
        end
        true
      end
    end
  end
end
