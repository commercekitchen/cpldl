module Admin::Custom::TranslationsHelper
  def translation_keys(i18n_locale)
    case i18n_locale
    when "en"
      en_keys
    when "jp"
      jp_keys
    else
      default_keys
    end
  end

  def translation_for_key(translations, key)
    hits = translations.to_a.select{ |t| t.key == key }
    hits.first
  end  

  private

  def en_keys
    [ "welcome", "site_description", "contact_name" ]
  end

  def jp_keys
    [ "welcome", "site_description" ]
  end

  def default_keys
    [ "welcome", "site_description" ]
  end
end