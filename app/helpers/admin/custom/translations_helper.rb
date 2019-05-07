module Admin::Custom::TranslationsHelper
  def translation_keys(i18n_locale)
    send("#{i18n_locale}_keys")
  end

  def translation_for_key(translations, key)
    hits = translations.to_a.select{ |t| t.key == key }
    hits.first
  end  

  private

  def en_keys
    %w(
      home.%{subdomain}.custom_banner_greeting
      home.%{subdomain}.logo_banner_html
      completed_courses_page.%{subdomain}.retake_the_quiz
      my_courses_page.%{subdomain}.course_color_explaination
    ).map { |k| k % { subdomain: current_organization.subdomain } }
  end

  def es_keys
    en_keys
  end

  def locale_string(i18n_locale)
    i18n_locale == :en ? 'English' : 'Español'
  end
end