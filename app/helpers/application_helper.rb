# frozen_string_literal: true

module ApplicationHelper
  def current_organization
    @current_organization ||= find_organization
  end

  def redirect_to_www
    redirect_to subdomain: 'www'
  end

  def tel_to(number)
    return '<no phone number>' if number.blank?

    link_to number_to_phone(number, area_code: true), "tel:#{number}"
  end

  def footer_logo_url
    current_organization.footer_logo.exists? ? current_organization.footer_logo.url : "#{current_organization.subdomain}_logo_footer.png"
  end

  def footer_logo_link_url
    links = {
      chipublib: 'http://www.chipublib.org/',
      npl: 'http://library.nashville.org',
      kpl: 'http://kpl.gov/',
      tscpl: 'http://tscpl.org/',
      pima: 'https://www.library.pima.gov',
      ebrpl: 'https://www.ebrpl.com',
      carnegielibrary: 'https://www.carnegielibrary.org',
      kclibrary: 'http://www.kclibrary.org/'
    }
    current_organization.footer_logo_link.presence || links[current_organization.subdomain.to_sym]
  end

  def user_sidebar(sidebar)
    if org_admin?
      sidebar ||= 'shared/admin/sidebar'
    else
      sidebar = 'shared/user/sidebar'
    end
    render sidebar
  end

  def org_admin?(user = current_user)
    user.present? && user.has_role?(:admin, current_organization)
  end

  def current_language
    language_string = I18n.locale == :es ? 'Spanish' : 'English'
    Language.find_by(name: language_string)
  end

  protected

  def find_organization
    org = Organization.find_by(subdomain: current_subdomain) || Organization.find_by(subdomain: 'www')

    unless org.subdomain == current_subdomain
      redirect_to_www && (return org)
    end

    org
  end

  def current_subdomain
    request.subdomain
  end
end
