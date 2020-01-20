# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Pundit

  before_action :current_organization
  before_action :set_locale
  before_action :set_cms_footer_pages
  before_action :set_cms_marketing_pages
  before_action :set_user_token
  before_action :require_valid_profile

  helper_method :subdomain?
  helper_method :top_level_domain?
  helper_method :hide_language_links?
  helper_method :in_subdomain?

  #after_action :verify_authorized, except: :index
  #after_action :verify_policy_scoped, only: :index

  ### TODO: Rework language settings to be more conventional

  #  around_action :switch_locale

  #  def default_url_options
  #    { locale: I18n.locale } unless I18n.locale == I18n.default_locale
  #  end
  #
  #  def switch_locale(&action)
  #    locale = language_preference || I18n.default_locale
  #    I18n.with_locale(locale, &action)
  #  end
  #
  #  def language_preference
  #    current_user&.locale || session[:locale]
  #  end

  def set_locale
    if current_user&.profile && current_user.profile.language.present?
      if user_language_override? == true
        I18n.locale = session[:locale].to_sym if session[:locale].present?
      else
        case current_user.profile.language.name
        when 'English'
          I18n.locale = :en
        when 'Spanish'
          I18n.locale = :es
        end
        session[:locale] = I18n.locale.to_s
      end
    else
      I18n.locale = session[:locale].nil? ? :en : session[:locale].to_sym
    end
  end

  def user_language_override?
    if current_user.profile.language.present?
      user_lang_abbrv2 = current_user.profile.language.name == 'English' ? 'en' : 'es'
      return true if session[:locale] != user_lang_abbrv2
    else
      false
    end
  end
  #########################

  def pundit_user
    current_user || GuestUser.new(organization: current_organization)
  end

  def require_valid_profile
    if invalid_user_profile?(current_user) || missing_profile?(current_user)
      flash[:alert] = 'You must have a valid profile before you can continue:'
      redirect_to invalid_profile_path
    end
  end

  def top_level_domain?
    current_organization.subdomain == 'www'
  end

  def subdomain?
    !(current_organization.subdomain == 'www' || current_organization.subdomain == '')
  end

  def after_sign_in_path_for(user)
    if org_admin?(user)
      admin_after_sign_in_path_for(user)
    else
      user_after_sign_in_path_for(user)
    end
  end

  def user_audience_list
    list = ['All']
    if user_signed_in?
      list << 'Auth'
      list << 'Admin' if org_admin?(current_user)
    else
      list << 'Unauth'
    end
    list
  end

  def set_cms_footer_pages
    org_id = current_organization.id

    @footer_pages = CmsPage.where(pub_status: 'P', language: current_language, organization_id: org_id, audience: user_audience_list)
  end

  def set_cms_marketing_pages
    @overview_page = CmsPage.find_by(title: 'Get DigitalLearn for Your Library')
    @customization_page = CmsPage.find_by(title: 'Pricing & Features')
    @portfolio_page = CmsPage.find_by(title: 'See Our Work In Action')
  end

  def first_time_login?
    current_user.present? && current_user.sign_in_count == 1 && current_user.profile.present? && current_user.profile.created_at.to_s == current_user.profile.updated_at.to_s
  end

  def hide_language_links?
    return true if params[:controller] == 'courses' && params[:action] != 'index'
    return true if params[:controller] == 'lessons'
    return true if params[:controller].starts_with? 'static'

    false
  end

  def in_subdomain?(subdomain)
    current_organization.subdomain == subdomain
  end

  protected

  def enable_sidebar(sidebar = nil)
    @show_sidebar = true
    @sidebar = sidebar
  end

  private

  def admin_after_sign_in_path_for(user)
    if user.profile.nil?
      flash[:notice] = 'This is the first time you have logged in, please update your profile.'
      profile_path
    elsif invalid_user_profile?(user)
      profile_path
    elsif org_admin?(user)
      admin_dashboard_index_path
    else
      root_path
    end
  end

  def user_after_sign_in_path_for(user)
    if first_time_login?
      flash[:notice] = 'This is the first time you have logged in, please update your profile.'
      profile_path
    elsif invalid_user_profile?(user)
      profile_path
    else
      root_path
    end
  end

  def invalid_user_profile?(user)
    user.present? && user.profile.present? && !user.profile.valid?
  end

  def missing_profile?(user)
    user.present? && user.profile.nil?
  end

  def set_user_token
    if current_user&.token
      session[:user_ga_id] = current_user.token
    elsif current_user && current_user.token.blank?
      current_user.send(:add_token_to_user)
      current_user.save(validate: false)
      session[:user_ga_id] = current_user.token
    else
      session[:user_ga_id] = 'guest'
    end
  end

end
