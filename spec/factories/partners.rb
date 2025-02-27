# frozen_string_literal: true

FactoryBot.define do
  factory :partner do
    name { "partner-#{Faker::Lorem.characters(number: 4)}" }
    association :organization, :accepts_partners
  end
end
