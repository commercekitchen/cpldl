# == Schema Information
#
# Table name: schools
#
#  id              :integer          not null, primary key
#  school_name     :string
#  enabled         :boolean          default(TRUE)
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryBot.define do
  factory :school do
    school_name { Faker::Hipster.sentence(3) }
    organization

    trait :disabled do
      enabled false
    end
  end
end
