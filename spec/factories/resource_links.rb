# frozen_string_literal: true

FactoryBot.define do
  factory :resource_link do
    course
    label { Faker::Lorem.sentence(word_count: 3) }
    url { Faker::Internet.url }
  end
end