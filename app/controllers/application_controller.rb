class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :set_locale
  before_action :set_language
  before_action :set_cms_footer_pages
  before_action :redirect_orgs
  before_action :set_user_token
  protect_from_forgery with: :exception

  layout proc { user_signed_in? || dl_subdomain ? "user/logged_in" : "application" }

  def after_sign_in_path_for(user)
    check_user_subdomain(user)
    if first_admin_login? user
      flash[:notice] = "This is the first time you have logged in, please change your password."
      profile_path
    elsif user.has_role?(:admin, Organization.find_by_subdomain(request.subdomain))
      admin_dashboard_index_path
    else
      root_path
    end
  end

  def check_user_subdomain(user)
    user_subdomain = user.try(:organization).subdomain
    if user_subdomain != request.subdomain
      user.update_attribute(:sign_in_count,  0) if user.sign_in_count == 1
      sign_out user
      flash[:alert] = %Q[Oops! You’re a member of Chicago Digital Learn. Sign in at <a href="http://#{user_subdomain}.digitallearn.org">#{user_subdomain}.digitallearn.org</a>]
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
      relative_path = request.original_fullpath
      relative_path[0] = ""
      redirect_to root_url(subdomain: "www") + relative_path
    end
  end

  def set_locale
    if current_user && current_user.profile && current_user.profile.language.blank? == false
      if user_language_override? == true
        I18n.locale = session[:locale].to_sym unless session[:locale].blank?
      else
        case current_user.profile.language.name
        when "English"
          I18n.locale = :en
        when "Spanish"
          I18n.locale = :es
        end
      end
    else
      I18n.locale = session[:locale].nil? ? :en : session[:locale].to_sym
    end
  end

  private

  def user_language_override?
    if current_user.profile.language.blank? == false
      user_lang_abbrv2 = current_user.profile.language_id == 1 ? "en" : "es"
      return true if session[:locale] != user_lang_abbrv2
    else
      return false
    end
  end

  # TODO: determine if we need to set the client_ID or if we can use googles
  # def save_google_analytics_client_id
  #   if current_user && cookies["_ga"]
  #     client_id = cookies["_ga"].split(".").last(2).join(".")
  #     if current_user.google_analytics_client_id != client_id
  #       current_user.google_analytics_client_id = client_id
  #       current_user.save
  #     end
  #   end
  # end

  # def set_user_token
  #   session[:user_ga_id] = current_user ? current_user.token : "guest"
  # end

  def dl_subdomain
    request.subdomain == "www"
  end

  def first_admin_login?(user)
    return true if user.sign_in_count == 1 && (user.is_super? || user.has_role?(:admin, Organization.find_by_subdomain(request.subdomain)))
    false
  end
end
