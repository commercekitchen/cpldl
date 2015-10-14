FactoryGirl.define do
  factory :user do
    email Faker::Internet.email
    password "abcd1234"
    confirmed_at Time.zone.now.to_s
    association :profile, factory: :profile
  end

  factory :unconfirmed_user, class: User do
    email Faker::Internet.email
    password "abcd1234"
    confirmed_at nil
  end

  factory :admin_user, class: User do
    email Faker::Internet.email
    password "abcd1234"
    confirmed_at Time.zone.now.to_s
  end

  factory :super_user, class: User do
    email Faker::Internet.email
    password "abcd1234"
    confirmed_at Time.zone.now.to_s
  end
end
