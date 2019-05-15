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
    {
      'home.%{subdomain}.custom_banner_greeting' => 'Custom banner greetings',
      'home.%{subdomain}.logo_banner_html' => 'Logo Banner Html',
      'home.choose_a_course.%{subdomain}' => 'Choose a course',
      'completed_courses_page.%{subdomain}.retake_the_quiz' => 'Retake the quiz',
      'my_courses_page.%{subdomain}.course_color_explaination' => 'Course color explaination'
    }.each_with_object({}) do |(k, v), obj|
      key = k % { subdomain: current_organization.subdomain }
      obj[key] = v
    end
  end

  def es_keys
    en_keys
  end

  def locale_string(i18n_locale)
    i18n_locale == :en ? 'English' : 'Español'
  end

  def default_org_i18n_key(key)
    key.gsub(current_organization.subdomain, 'default_org')
  end

end