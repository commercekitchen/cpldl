# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :skip_authorization

      def show
        render json: profile_payload
      end

      def update
        profile = Profile.find_or_initialize_by(user: current_user)
        previous_language_id = profile.language_id

        if profile.context_update(profile_params)
          update_locale(profile) if previous_language_id != profile.language_id
          render json: profile_payload(profile), status: :ok
        else
          render status: :unprocessable_entity, json: { errors: profile.errors.full_messages }
        end
      end

      private

      def profile_payload(profile = nil)
        p = profile || Profile.find_or_initialize_by(user: current_user)

        {
          profile: {
            firstName: p.first_name,
            zipCode: p.zip_code,
            languageId: p.language_id
          },
          languages: Language.all.order(:name).map { |lang| { id: lang.id, name: lang.name } }
        }
      end

      def profile_params
        raw = params.fetch(:profile, {}).permit(:language_id, :first_name, :zip_code)
        raw[:language_id] = raw[:language_id].presence
        raw
      end

      def update_locale(profile)
        language = Language.find_by(id: profile.language_id) || Language.first
        I18n.locale = language&.name == 'Spanish' ? :es : :en
        session[:locale] = I18n.locale.to_s
      end
    end
  end
end

