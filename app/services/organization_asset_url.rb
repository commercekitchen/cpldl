# frozen_string_literal: true

class OrganizationAssetUrl
  EXTENSIONS = %w[svg png jpg jpeg].freeze

  def self.logo_url_for(org, request:)
    # Future: if org has ActiveStorage logo, use that
    if org.respond_to?(:logo) && org.logo.attached?
      return Rails.application.routes.url_helpers.rails_blob_url(
        org.logo,
        host: request.base_url
      )
    end

    # Predictable legacy asset fallback
    path = find_first_existing_asset_path(
      "#{org.subdomain}_logo_header",
      request: request
    ) || find_first_existing_asset_path(
      'dl_logo',
      request: request
    )

    # If still nothing, nil (or a hardcoded generic)
    return nil unless path

    asset_url(path, request: request)
  end

  def self.find_first_existing_asset_path(base_path, request:)
    EXTENSIONS.each do |ext|
      candidate = "#{base_path}.#{ext}"
      return candidate if asset_exists?(candidate)
    end
    nil
  end

  def self.asset_exists?(logical_path)
    if Rails.env.production? || Rails.env.staging?
      Rails.application.assets_manifest.assets[logical_path].present?
    else
      Rails.application.assets&.find_asset(logical_path).present?
    end
  rescue StandardError
    false
  end

  def self.asset_url(logical_path, request:)
    # This returns an absolute URL so React can just use it directly.
    helpers = ActionController::Base.helpers
    url = helpers.asset_path(logical_path) # may include digest in prod
    URI.join(request.base_url, url).to_s
  end
end
