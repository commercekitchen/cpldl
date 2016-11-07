# == Schema Information
#
# Table name: profiles
#
#  id                  :integer          not null, primary key
#  first_name          :string
#  zip_code            :string
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  language_id         :integer
#  library_location_id :integer
#  acting_as           :integer          default(0)
#  last_name           :string
#  phone               :string
#  street_address      :string
#  city                :string
#  state               :string
#  library_card_number :string
#  student_id          :string
#  date_of_birth       :datetime
#  grade               :integer
#  school_id           :integer
#

FactoryGirl.define do
  factory(:profile) do
    first_name "Jane"
    zip_code "90210"
    language_id 1
  end

end
