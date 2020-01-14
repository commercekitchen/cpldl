class GuestUser
  attr_reader :organization

  def initialize(organization:)
    @organization = organization
  end
end