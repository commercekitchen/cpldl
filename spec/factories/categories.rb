FactoryGirl.define do
  factory :category do
    name { Faker::Lorem.word }
    organization
  end
end