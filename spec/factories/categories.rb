# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    name { Faker::Lorem.words(number: 3).join(' ') }
    organization

    trait :disabled do
      enabled { false }
    end
  end
end
