# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :current_organization

      # after_action :verify_authorized
      # after_action :verify_policy_scoped

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      private

      def current_organization
        @current_organization ||= OrganizationResolver.resolve(subdomain: request.subdomain)
      end

      def user_not_authorized
        render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
      end
    end
  end
end
