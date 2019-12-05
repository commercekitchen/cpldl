# frozen_string_literal: true

module Admin
  class InvitesController < Devise::InvitationsController
    def create
      user = User.find_by(email: params[:user][:email])
      if user
        flash[:alert] = 'The user already exists'
        redirect_to admin_dashboard_admin_invitation_path
      else
        super
      end
    end

    private

    def invite_resource
      organization = if params[:user][:organization_id]
                       Organization.find(params[:user][:organization_id])
                     else
                       current_organization
                     end

      AdminInvitationService.invite(email: params[:user][:email], organization: organization, inviter: current_user)
    end
  end
end
