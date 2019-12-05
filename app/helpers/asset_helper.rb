# frozen_string_literal: true

module AssetHelper
  def asset_exists?(path)
    if Rails.env.production? || Rails.env.staging?
      Rails.application.assets_manifest.assets[path].present?
    else
      Rails.application.assets.find_asset(path).present?
    end
  end

  def asset_with_extension(path)
    %w[png svg jpg].each do |extension|
      candidate = "#{path}.#{extension}"
      return candidate if asset_exists?(candidate)
    end
    path
  end

  def safe_image_tag(source, options = {})
    image_tag(asset_with_extension(source), options)
  rescue Sprockets::Rails::Helper::AssetNotFound
    nil
  end
end
