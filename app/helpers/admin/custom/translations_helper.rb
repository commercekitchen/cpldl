# frozen_string_literal: true

module Admin
  module Custom
    module TranslationsHelper
      def translation_keys(i18n_locale)
        send("#{i18n_locale}_keys")
      end

      def translation_for_key(translations, key)
        hits = translations.to_a.select { |t| t.key == key }
        hits.first
      end

      def locale_string(i18n_locale)
        i18n_locale.to_s == 'es' ? 'Spanish' : 'English'
      end

      def default_org_i18n_key(key)
        key.gsub(current_organization.subdomain, 'default_org')
      end

      def i18n_with_default(key)
        t(key, default: t(default_org_i18n_key(key)))
      end

      private

      def en_keys
        texts = {
          'home.%<subdomain>s.custom_banner_greeting' => 'Homepage Greeting',
          'home.choose_a_course.%<subdomain>s' => 'Course Selection Greeting',
          'completed_courses_page.%<subdomain>s.retake_the_quiz' => 'Retake the Quiz Button'
        }

        # texts['course_completion_page.%{subdomain}.user_survey_button_text'] = 'User Survey Button Text'

        texts.each_with_object({}) do |(k, v), obj|
          key = format(k, subdomain: current_organization.subdomain)
          obj[key] = v
        end
      end

      def es_keys
        en_keys
      end
    end
  end
end
