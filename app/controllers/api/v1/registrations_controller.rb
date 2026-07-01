# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < Api::V1::BaseController
      before_action :skip_authorization

      def create
        unless sign_up_allowed?
          render status: :forbidden, json: { message: 'Sign-up is not allowed for this organization.' }
          return
        end

        user = User.new(registration_params.merge(organization_id: current_organization.id))

        unless user.save
          render status: :unprocessable_entity, json: { message: user.errors.full_messages.join(', ') }
          return
        end

        user.add_role(:user, current_organization)
        sign_in(:user, user)

        render status: :created, json: {
          id: user.id,
          email: user.email,
          organization_subdomain: user.organization.subdomain
        }
      end

      private

      def registration_params
        params.permit(:email, :password, :password_confirmation)
      end

      def sign_up_allowed?
        !current_organization.phone_number_users_enabled
      end
    end
  end
end
