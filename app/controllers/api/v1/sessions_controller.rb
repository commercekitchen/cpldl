# frozen_string_literal: true

module Api
  module V1
    class SessionsController < Api::V1::BaseController
      before_action :skip_authorization

      def create
        email = login_params[:email].to_s.strip.downcase
        password = login_params[:password].to_s

        user = User.find_for_authentication(email: email)

        if user.blank? || user.organization_id != current_organization.id || !user.valid_password?(password)
          render status: :unauthorized, json: { message: 'Invalid email or password.' }
          return
        end

        sign_in(:user, user)

        render json: {
          id: user.id,
          email: user.email,
          organization_subdomain: user.organization.subdomain,
          is_org_admin: user.has_role?(:admin, user.organization),
          redirect_to: post_login_redirect_for(user)
        }
      end

      def destroy
        sign_out(:user) if current_user
        render json: { ok: true }
      end

      private

      def login_params
        params.permit(:email, :password)
      end

      def post_login_redirect_for(user)
        stored_location_for(user) || (user.has_role?(:admin, user.organization) ? '/admin' : '/')
      end
    end
  end
end
