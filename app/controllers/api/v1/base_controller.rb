# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include ApplicationHelper
      include ActionController::Cookies
      include ActionController::RequestForgeryProtection
      include Pundit::Authorization
      include LocaleSetting

      before_action :current_organization
      protect_from_forgery with: :exception

      # after_action :verify_authorized
      # after_action :verify_policy_scoped

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_authenticity_token

      def pundit_user
        current_user || GuestUser.new(organization: current_organization)
      end

      private

      def state_changing_request?
        request.post? || request.put? || request.patch? || request.delete?
      end

      def origin_from_referer
        return nil if request.referer.blank?

        referer_uri = URI.parse(request.referer)
        origin = "#{referer_uri.scheme}://#{referer_uri.host}"
        default_port = referer_uri.scheme == 'https' ? 443 : 80
        origin += ":#{referer_uri.port}" if referer_uri.port && referer_uri.port != default_port
        origin
      rescue URI::InvalidURIError
        nil
      end

      def current_organization
        @current_organization ||= OrganizationResolver.resolve(subdomain: request.subdomain)
      end

      def user_not_authorized
        render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
      end

      def invalid_authenticity_token
        render status: :unprocessable_entity, json: { message: 'Invalid CSRF token.' }
      end
    end
  end
end
