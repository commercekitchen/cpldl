# frozen_string_literal: true

FactoryBot.define do

  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
    sequence(:subdomain) { |n| "org-#{n}" }

    trait :accepts_programs do
      accepts_programs true
    end

    trait :library_card_login do
      library_card_login true
    end

    trait :no_login_required do
      login_required false
    end

    trait :accepts_partners do
      accepts_partners true
    end

    factory :chicago do
      name 'Chicago Public Library'
      subdomain 'chipublib'
    end

    factory :default_organization do
      name 'Digital Learn'
      subdomain 'www'
      login_required false
    end
  end
end
