# frozen_string_literal: true

class GuestUser
  attr_reader :organization, :uuid

  def initialize(organization:)
    @organization = organization
    @uuid = SecureRandom.uuid
  end

  def admin?
    false
  end

  def trainer?
    false
  end
end
