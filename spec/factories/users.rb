# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    organization
    sequence(:email) { |n| "jane#{n}@example.com" }
    password { 'abcd1234' }
    sign_in_count { 2 }
    profile { build(:profile, user: nil) }

    after(:create) do |user|
      user.add_role(:user, user.organization)
    end

    trait :library_card_login_user do
      email { nil }
      library_card_number { Array.new(7) { rand(10) }.join }
      library_card_pin { Array.new(4) { rand(10) }.join }

      before(:create) do |user|
        user.password = Digest::MD5.hexdigest(user.library_card_pin).first(10)
      end
    end

    trait :with_last_name do
      profile { build(:profile, :with_last_name, user: nil) }
    end

    trait :first_time_user do
      sign_in_count { 0 }
    end

    trait :admin do
      after(:create) do |user|
        user.roles.destroy_all
        user.add_role(:admin, user.organization)
      end
    end

    trait :trainer do
      after(:create) do |user|
        user.roles.destroy_all
        user.add_role(:trainer, user.organization)
      end
    end

    trait :parent do
      after(:create) do |user|
        user.roles.destroy_all
        user.add_role(:parent, user.organization)
      end
    end

    trait :student do
      after(:create) do |user|
        user.roles.destroy_all
        user.add_role(:student, user.organization)
      end
    end
  end

  factory :phone_number_user, class: 'User' do
    phone_number { 10.times.map { rand(10) }.join('') }
    organization { FactoryBot.create(:organization, phone_number_users_enabled: true) }

    after(:create) do |user|
      user.add_role(:user, user.organization)
    end
  end
end
