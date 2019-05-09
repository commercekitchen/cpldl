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

  def footer_logo_url
    current_organization.footer_logo.exists? ? current_organization.footer_logo.url : "#{current_organization.subdomain}_logo_white"
  end

  def footer_logo_link_url
    links = {
      chipublib: "http://www.chipublib.org/",
      npl: "http://library.nashville.org",
      kpl: "http://kpl.gov/",
      tscpl: "http://tscpl.org/",
      pima: "https://www.library.pima.gov",
      ebrpl: "https://www.ebrpl.com",
      carnegielibrary: "https://www.carnegielibrary.org",
      kclibrary: "http://www.kclibrary.org/"
    }
    current_organization.footer_logo_link.present? ? current_organization.footer_logo_link : links[current_organization.subdomain.to_sym]
  end
end
