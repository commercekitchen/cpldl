class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :set_locale
  before_action :set_language
  before_action :set_cms_footer_pages
  before_action :redirect_chicago
  protect_from_forgery with: :exception

  layout proc { user_signed_in? ? "user/logged_in" : "application" }

  def after_sign_in_path_for(user)
    if first_admin_login? user
      flash[:notice] = "This is the first time you have logged in, please change your password."
      profile_path
    elsif user.is_admin?
      admin_dashboard_index_path
    else
      root_path
    end
  end

  def set_language
    @language = Language.find_by(id: 1) unless Language.all.blank?
  end

  def set_cms_footer_pages
    @footer_pages = CmsPage.where(pub_status: "P")
  end

  def redirect_chicago
    case request.subdomain
    when "chicago"
      redirect_to root_url(subdomain: "chipublib")
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

  def first_admin_login?(user)
    return true if user.sign_in_count == 1 && (user.is_super? || user.is_admin?)
    false
  end
end
