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
#  login_required          :boolean          default(TRUE)
#

FactoryBot.define do
  factory :organization do
    name "Chicago Public Library"
    subdomain "chipublib"

    trait :accepts_programs do
      accepts_programs true
    end

    trait :library_card_login do
      library_card_login true
    end

    trait :no_login_required do
      login_required false
    end

    factory :default_organization do
      name "Digital Learn"
      subdomain "www"
      login_required false
    end
  end
end
