# frozen_string_literal: true

class AdminInvitationService
  def self.invite(email:, organization:, inviter: nil)
    User.invite!({ email: email }, inviter) do |u|
      u.organization = organization
      u.skip_invitation = true
      u.add_role(:admin, organization)
      u.deliver_invitation
    end
  end
end
