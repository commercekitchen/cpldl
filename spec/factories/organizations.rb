# == Schema Information
#
# Table name: organizations
#
#  id               :integer          not null, primary key
#  name             :string
#  subdomain        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  branches         :boolean
#  accepts_programs :boolean
#

FactoryGirl.define do
  factory :organization do
    name "Chicago Public Library"
    subdomain "chipublib"

    trait :accepts_programs do
      accepts_programs true
    end
  end
end
