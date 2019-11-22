# frozen_string_literal: true

FactoryBot.define do
  factory :partner do
    name { Faker::Lorem.characters(number: 10) }
    association :organization, :accepts_partners
  end
end
