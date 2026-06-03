# frozen_string_literal: true

module LocaleSetting
  extend ActiveSupport::Concern

  SUPPORTED_LOCALES = %w[en es].freeze

  included do
    before_action :set_locale
  end

  def set_locale
    if current_user&.profile && current_user.profile.language.present?
      if user_language_override?
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

  private

  def user_language_override?
    return false if current_user.profile.language.blank?

    user_lang = current_user.profile.language.name == 'English' ? 'en' : 'es'
    session[:locale] != user_lang
  end
end
