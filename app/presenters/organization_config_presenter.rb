# frozen_string_literal: true

require 'cgi'

class OrganizationConfigPresenter
  def initialize(organization, request:)
    @organization = organization
    @request = request
  end

  def as_json
    {
      subdomain: @organization.subdomain,
      displayName: @organization.name,
      bannerText: banner_text,

      theme: {
        logoUrl: OrganizationAssetUrl.logo_url_for(@organization, request: @request),
        footerLogoUrl: @organization.footer_logo&.url,
        footerLogoDestinationUrl: @organization.footer_logo_link,
        primaryColor: @organization.primary_color || DefaultTheme::PRIMARY_COLOR,
        secondaryColor: @organization.secondary_color || DefaultTheme::SECONDARY_COLOR,
        fontFamily: @organization.font_family || DefaultTheme::FONT_FAMILY,
        radius: @organization.theme_radius || DefaultTheme::RADIUS
      }.compact,

      features: {
        phoneNumberSignIn: @organization.phone_number_users_enabled,
        signUpAllowed: !@organization.main_site?,
        surveyRequired: @organization.survey_required,
        userSurveyEnabled: @organization.user_survey_enabled,
        userSurveyLink: @organization.user_survey_link,
        spanishSurveyLink: @organization.spanish_survey_link
      }
    }
  end

  private

  def banner_text
    CGI.unescape_html(i18n_with_default("home.#{@organization.subdomain}.custom_banner_greeting"))
  end

  def i18n_with_default(key)
    I18n.t(key, default: I18n.t(default_org_i18n_key(key)))
  end

  def default_org_i18n_key(key)
    key.gsub(@organization.subdomain, 'default_org')
  end
end
