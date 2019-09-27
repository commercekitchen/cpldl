# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  name            :string
#  category_order  :integer
#  organization_id :integer
#  enabled         :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryBot.define do
  factory :category do
    name { Faker::Lorem.words(3).join(" ") }
    organization

    trait :disabled do
      enabled false
    end
  end
end
