FactoryGirl.define do
  factory :user do
    email "user@commercekitchen.com"
    password "abcd1234"
    confirmed_at Time.zone.now.to_s
    association :profile, factory: :profile
  end

  factory :unconfirmed_user, class: User do
    email "user+1@commercekitchen.com"
    password "abcd1234"
    confirmed_at nil
  end
end
