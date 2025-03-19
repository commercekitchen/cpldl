# frozen_string_literal: true

FactoryBot.define do
  factory(:profile) do
    language
    first_name { Faker::Name.first_name }
    zip_code { '90210' }
    user { build(:user, profile: nil) }

    trait :with_last_name do
      last_name { Faker::Name.last_name }
    end
  end
end
