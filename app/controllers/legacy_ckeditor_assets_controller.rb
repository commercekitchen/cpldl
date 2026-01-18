class LegacyCkeditorAssetsController < ApplicationController
  skip_before_action :authenticate_user!

  def attachment
    asset = Ckeditor::AttachmentFile.find(params[:id])

    # Prefer ActiveStorage if migrated
    if asset.respond_to?(:data_file) && asset.data_file.attached?
      return redirect_to_active_storage(asset.data_file)
    end

    # Fallback to Paperclip (pre-migration)
    if asset.respond_to?(:data) && asset.data.exists?
      return redirect_to(asset.data.url, allow_other_host: true)
    end

    head :not_found
  end

  def picture
    asset = Ckeditor::Picture.find(params[:id])
    style = normalize_style(params[:style])

    # Prefer ActiveStorage if migrated
    if asset.respond_to?(:data_file) && asset.data_file.attached?
      return redirect_picture_active_storage(asset, style)
    end

    # Fallback to Paperclip (pre-migration)
    if asset.respond_to?(:data) && asset.data.exists?
      # Paperclip will generate the correct CloudFront URL because you set:
      # url: ":s3_alias_url", s3_host_alias: cloudfront_host
      return redirect_to(asset.data.url(style), allow_other_host: true)
    end

    head :not_found
  end

  private

  def normalize_style(style_param)
    s = style_param.to_s.downcase
    return :thumb if s == "thumb"
    return :content if s == "content"
    :original
  end

  def redirect_to_active_storage(attached)
    # Uses Rails blob route (signed). If you later want CDN URLs, you can change this.
    url = Rails.application.routes.url_helpers.rails_blob_url(attached, disposition: "inline")
    redirect_to(url, allow_other_host: true)
  end

  def redirect_picture_active_storage(asset, style)
    helpers = Rails.application.routes.url_helpers

    case style
    when :thumb
      variant = asset.variant_thumb
      url = helpers.rails_representation_url(variant.processed, disposition: "inline")
    when :content
      variant = asset.variant_content
      url = helpers.rails_representation_url(variant.processed, disposition: "inline")
    else
      url = helpers.rails_blob_url(asset.data_file, disposition: "inline")
    end

    redirect_to(url, allow_other_host: true)
  end
end
