# frozen_string_literal: true

FactoryBot.define do
  factory :program_location do
    location_name Faker::Lorem.word
    program

    trait :disabled do
      enabled false
    end
  end
end
