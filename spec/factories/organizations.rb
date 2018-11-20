# == Schema Information
#
# Table name: organizations
#
#  id                      :integer          not null, primary key
#  name                    :string
#  subdomain               :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  branches                :boolean
#  accepts_programs        :boolean
#  library_card_login      :boolean          default(FALSE)
#  accepts_custom_branches :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :organization do
    name "Chicago Public Library"
    subdomain "chipublib"

    trait :accepts_programs do
      accepts_programs true
    end

    trait :library_card_login do
      library_card_login true
    end
  end
end
