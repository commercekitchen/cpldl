# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    organization
    school_name { Faker::Lorem.sentence(word_count: 3) }
    school_type { :middle }

    trait :disabled do
      enabled { false }
    end
  end
end
