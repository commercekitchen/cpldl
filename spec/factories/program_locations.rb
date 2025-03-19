# frozen_string_literal: true

FactoryBot.define do
  factory :program_location do
    program
    location_name { Faker::Lorem.word }

    trait :disabled do
      enabled { false }
    end
  end
end
