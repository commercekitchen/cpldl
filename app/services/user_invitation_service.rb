# frozen_string_literal: true

class UserInvitationService
  ALLOWED_ROLES = %w[user admin trainer].freeze

  def self.invite(email:, organization:, role: 'user', inviter: nil)
    User.invite!({ email: email }, inviter) do |u|
      u.organization = organization
      u.skip_invitation = true
      u.add_role(role.to_sym, organization)
      u.deliver_invitation
    end
  end
end
