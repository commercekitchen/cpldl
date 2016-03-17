module Admin
  class InvitesController < Devise::InvitationsController
    private

    def invite_resource
      User.invite!({ email: params[:user][:email] }, current_user) do |u|
        u.skip_invitation = true
        u.add_role(:admin, Organization.find_by_subdomain(request.subdomain))
        u.deliver_invitation
      end
    end
  end
end
