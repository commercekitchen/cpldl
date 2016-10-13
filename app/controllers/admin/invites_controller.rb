module Admin
  class InvitesController < Devise::InvitationsController
    private

    def invite_resource
      organization = Organization.find(params[:user][:organization_id]) || current_organization
      User.invite!({ email: params[:user][:email] }, current_user) do |u|
        u.organization = organization
        u.skip_invitation = true
        u.add_role(:admin, organization)
        u.deliver_invitation
      end
    end
  end
end
