# frozen_string_literal: true

# == Schema Information
#
# Table name: program_locations
#
#  id            :integer          not null, primary key
#  location_name :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  enabled       :boolean          default(TRUE)
#  program_id    :integer
#

FactoryBot.define do
  factory :program_location do
    location_name Faker::Hipster.word
    program

    trait :disabled do
      enabled false
    end
  end
end
