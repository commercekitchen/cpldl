# frozen_string_literal: true

require 'cgi'

class OrganizationConfigPresenter
  def initialize(organization, request:, current_user: nil)
    @organization = organization
    @request = request
    @current_user = current_user
  end

  def as_json
    {
      subdomain: @organization.subdomain,
      displayName: @organization.name,
      mainSite: @organization.main_site?,
      bannerText: banner_text,
      customText: custom_text_payload,
      trainingSiteLink: @organization.training_site_link.presence,
      footerLinks: footer_links_payload,

      theme: {
        logoUrl: OrganizationAssetUrl.logo_url_for(@organization, request: @request),
        footerLogoUrl: footer_logo_url,
        footerLogoDestinationUrl: @organization.footer_logo_link,
        plaFooterLogoUrl: ActionController::Base.helpers.asset_path('pla_logo_footer.png'),
        plaFooterLogoDestinationUrl: 'http://www.ala.org/pla/',
        primaryColor: safe_color(@organization.primary_color, DefaultTheme::PRIMARY_COLOR),
        secondaryColor: safe_color(@organization.secondary_color, DefaultTheme::SECONDARY_COLOR),
        fontFamily: @organization.font_family || DefaultTheme::FONT_FAMILY,
        radius: @organization.theme_radius || DefaultTheme::RADIUS
      }.compact,

      features: {
        loginRequired: @organization.login_required,
        phoneNumberSignIn: @organization.phone_number_users_enabled,
        signUpAllowed: !@organization.phone_number_users_enabled,
        surveyRequired: @organization.survey_required,
        userSurveyEnabled: @organization.user_survey_enabled,
        userSurveyLink: @organization.user_survey_link,
        spanishSurveyLink: @organization.spanish_survey_link,
        userSurveyUrl: @organization.survey_url(I18n.locale, user: @current_user),
        userSurveyButtonText: i18n_with_default("course_completion_page.#{@organization.subdomain}.user_survey_button_text")
      }
    }
  end

  private

  def safe_color(value, default)
    value.present? && value.match?(Organization::HEX_COLOR_REGEX) ? value : default
  end

  def banner_text
    CGI.unescape_html(i18n_with_default("home.#{@organization.subdomain}.custom_banner_greeting"))
  end

  def custom_text_payload
    {
      homeHeaderEn: @organization.home_header_en.presence,
      homeSubheaderEn: @organization.home_subheader_en.presence,
      homeHeaderEs: @organization.home_header_es.presence,
      homeSubheaderEs: @organization.home_subheader_es.presence,
      customFooterMessageEn: @organization.custom_footer_message_en.presence,
      customFooterMessageEs: @organization.custom_footer_message_es.presence
    }.compact
  end

  def footer_logo_url
    return nil unless @organization.footer_logo_file.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      @organization.footer_logo_file,
      host: @request.base_url
    )
  end

  def i18n_with_default(key)
    I18n.t(key, default: I18n.t(default_org_i18n_key(key)))
  end

  def default_org_i18n_key(key)
    key.gsub(@organization.subdomain, 'default_org')
  end

  def footer_links_payload
    pages = CmsPage.where(
      pub_status: 'P',
      language: current_language,
      organization_id: @organization.id,
      audience: user_audience_list
    )

    links = FooterLink.where(
      organization_id: @organization.id,
      language: current_language
    )

    page_payload = pages.map do |page|
      {
        title: page.title,
        url: Rails.application.routes.url_helpers.cms_page_path(page),
        openInNewTab: false,
        isInternal: true
      }
    end

    link_payload = links.map do |link|
      {
        title: link.label,
        url: link.url,
        openInNewTab: true
      }
    end

    page_payload + link_payload
  end

  def user_audience_list
    list = ['All']
    if @current_user.present?
      list << 'Auth'
      list << 'Admin' if @current_user.has_role?(:admin, @organization)
    else
      list << 'Unauth'
    end
    list
  end

  def current_language
    language_string = I18n.locale == :es ? 'Spanish' : 'English'
    Language.find_by(name: language_string)
  end
end
