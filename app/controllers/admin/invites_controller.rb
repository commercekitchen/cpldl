module Admin
  class InvitesController < Devise::InvitationsController
    private

    def invite_resource
      User.invite!({ email: params[:user][:email] }, current_user) do |u|
        u.skip_invitation = true
        u.add_role(:admin, current_organization)
        u.deliver_invitation
      end
    end
  end
end
