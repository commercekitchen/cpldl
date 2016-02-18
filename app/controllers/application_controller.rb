class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :set_locale
  before_action :set_language
  before_action :set_cms_footer_pages
  before_action :redirect_orgs
  protect_from_forgery with: :exception

  layout proc { user_signed_in? || dl_subdomain ? "user/logged_in" : "application" }

  def after_sign_in_path_for(user)
    if first_admin_login? user
      flash[:notice] = "This is the first time you have logged in, please change your password."
      profile_path
    elsif user.has_role?(:admin, Organization.find_by_subdomain(request.subdomain))
      admin_dashboard_index_path
    else
      root_path
    end
  end

  def set_language
    @language = Language.find_by(id: 1) unless Language.all.blank?
  end

  def set_cms_footer_pages
    english_id = Language.find_by_name("English").try(:id) || 1
    spanish_id = Language.find_by_name("Spanish").try(:id) || 2
    org_id = Organization.find_by_subdomain(request.subdomain)
    case I18n.locale
    when :es
      @footer_pages = CmsPage.where(pub_status: "P", language_id: spanish_id, organization_id: org_id)
    else
      @footer_pages = CmsPage.where(pub_status: "P", language_id: english_id, organization_id: org_id)
    end
  end

  def redirect_orgs
    case request.subdomain
    when "chicago"
      redirect_to root_url(subdomain: "chipublib")
    when "admin"
      redirect_to root_url(subdomain: "www")
    when ""
      redirect_to root_url(subdomain: "www")
    end
  end

  def set_locale
    if current_user && current_user.profile && current_user.profile.language
      case current_user.profile.language.name
      when "English"
        I18n.locale = :en
      when "Spanish"
        I18n.locale = :es
      end
    else
      I18n.locale = session["locale"] || :en
    end
  end

  private

  def dl_subdomain
    request.subdomain == "www"
  end

  def first_admin_login?(user)
    return true if user.sign_in_count == 1 && (user.is_super? || user.has_role?(:admin, Organization.find_by_subdomain(request.subdomain)))
    false
  end
end
