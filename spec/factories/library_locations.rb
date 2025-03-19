# frozen_string_literal: true

FactoryBot.define do
  factory :library_location do
    organization
    name { "branch-#{Faker::Lorem.words(number: 2).join(' ')}" }
    zipcode { '87654' }
  end
end
