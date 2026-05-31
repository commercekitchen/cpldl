# frozen_string_literal: true

class SpaConstraint
  def matches?(request)
    sub = request.subdomain.presence || 'www'
    Organization.find_by(subdomain: sub)&.use_spa?
  end
end
