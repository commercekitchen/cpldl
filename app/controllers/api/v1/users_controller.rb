module Api
  module V1
    class UsersController < Api::V1::BaseController
      def me
        skip_authorization
        user = current_user || current_resource_owner

        unless user
          render status: :unauthorized, json: { message: 'Not authenticated.' }
          return
        end

        render json: {
          id: user.id,
          email: user.email,
          phoneNumber: user.phone_number,
          organization_subdomain: user.organization.subdomain,
          is_org_admin: user.has_role?(:admin, user.organization)
        }
      end

      private

      # Find the resource owner (user) using Doorkeeper's token association
      def current_resource_owner
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end
