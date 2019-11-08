# frozen_string_literal: true

FactoryBot.define do
  factory :language do
    initialize_with { Language.find_or_create_by(name: 'English') }
  end

  factory :spanish_lang, class: Language do
    initialize_with { Language.find_or_create_by(name: 'Spanish') }
  end
end
