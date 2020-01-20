# frozen_string_literal: true

class GuestUser
  attr_reader :organization

  def initialize(organization:)
    @organization = organization
  end

  def admin?
    false
  end

  def trainer?
    false
  end
end
