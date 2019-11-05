# frozen_string_literal: true

# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :language do
    initialize_with { Language.find_or_create_by(name: 'English') }
  end

  factory :spanish_lang, class: Language do
    initialize_with { Language.find_or_create_by(name: 'Spanish') }
  end
end
