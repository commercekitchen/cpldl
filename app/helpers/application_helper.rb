module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def svg_tag(filename, options = {})
    assets = Rails.application.assets
    file = assets.find_asset(filename).source.force_encoding("UTF-8")
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css "svg"
    svg["class"] = options[:class] if options[:class].present?
    raw doc
  end

  def tel_to(number)
    return "<no phone number>" if number.blank?
    link_to number_to_phone(number, area_code: true), "tel:#{number}"
  end
end
