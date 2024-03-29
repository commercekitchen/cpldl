# frozen_string_literal: true

FactoryBot.define do
  factory :footer_link do
    organization
    label { Faker::Lorem.sentence(word_count: 3) }
    url { Faker::Internet.url }
    language
  end
end
