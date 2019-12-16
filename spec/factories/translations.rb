# frozen_string_literal: true

FactoryBot.define do
  factory :translation do
    locale { :en }
    key { Faker::Lorem.word }
    value { Faker::Lorem.word }
  end
end
