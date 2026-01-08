# app/services/organization_resolver.rb
class OrganizationResolver
  TENANT_ALIASES = { "chicago" => "chipublib" }.freeze

  def self.resolve(subdomain:)
    requested = (subdomain.presence || "www")
    requested = TENANT_ALIASES[requested] || requested

    org = Organization.active.find_by(subdomain: requested)
    org ||= Organization.find_by(subdomain: "www")

    org
  end
end
