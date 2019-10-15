# frozen_string_literal: true

module Admin
  class InvitesController < Devise::InvitationsController
    def create
      user = User.find_by(email: params[:user][:email])
      if user
        flash[:alert] = 'The user already exists'
        redirect_to admin_invites_index_path
      else
        super
      end
    end

    private

    def invite_resource
      if params[:user][:organization_id]
        organization = Organization.find(params[:user][:organization_id])
      else
        organization = current_organization
      end
      User.invite!({ email: params[:user][:email] }, current_user) do |u|
        u.organization = organization
        u.skip_invitation = true
        u.add_role(:admin, organization)
        u.deliver_invitation
      end
    end
  end
end
