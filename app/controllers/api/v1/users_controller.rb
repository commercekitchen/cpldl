module Api
  module V1
    class UsersController < ApplicationController
      before_action :doorkeeper_authorize! # Require a valid access token

      def me
        # TODO: Authorize with Pundit
        skip_authorization # Skip required Pundit authorization (for now)

        # Assuming the user is authenticated through Doorkeeper
        user = current_resource_owner

        render json: {
          id: user.id,
          email: user.email,
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
