# == Schema Information
#
# Table name: profiles
#
#  id                         :integer          not null, primary key
#  first_name                 :string
#  zip_code                   :string
#  user_id                    :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  language_id                :integer
#  library_location_id        :integer
#  last_name                  :string
#  phone                      :string
#  street_address             :string
#  city                       :string
#  state                      :string
#  opt_out_of_recommendations :boolean          default(FALSE)
#

FactoryGirl.define do
  factory(:profile) do
    first_name Faker::Name.first_name
    zip_code "90210"
    language

    trait :with_last_name do
      last_name Faker::Name.last_name
    end
  end
end
