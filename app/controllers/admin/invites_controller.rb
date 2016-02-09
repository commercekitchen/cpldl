module Admin
  class InvitesController < Devise::InvitationsController
    private

    def invite_resource
      user = User.invite!({email: params[:user][:email]}, current_user) do |u|
        u.skip_invitation = true
        org_name = URI.parse(request.original_url).host.split(".")[0]
        u.add_role(:admin, Organization.find_by(name: org_name))
        u.deliver_invitation
      end
    end
  end
end