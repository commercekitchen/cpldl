# frozen_string_literal: true

module Api
  module V1
    class LocalesController < Api::V1::BaseController
      begin
        skip_after_action :verify_authorized
      rescue StandardError
        nil
      end

      def show
        render json: { locale: I18n.locale.to_s }
      end

      def update
        requested = params[:locale].to_s.downcase
        locale = LocaleSetting::SUPPORTED_LOCALES.include?(requested) ? requested : 'en'
        session[:locale] = locale
        I18n.locale = locale.to_sym
        render json: { locale: I18n.locale.to_s }
      end
    end
  end
end
