# frozen_string_literal: true

FactoryBot.define do
  factory :library_location do
    name { "branch-#{Faker::Lorem.words(number: 2).join(' ')}" }
    zipcode '87654'
    organization
  end
end
