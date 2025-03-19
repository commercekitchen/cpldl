# frozen_string_literal: true

FactoryBot.define do
  factory :footer_link do
    organization
    language
    label { Faker::Lorem.sentence(word_count: 3) }
    url { Faker::Internet.url }
  end
end
