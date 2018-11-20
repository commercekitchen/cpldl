# == Schema Information
#
# Table name: library_locations
#
#  id              :integer          not null, primary key
#  name            :string
#  zipcode         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#  sort_order      :integer          default(0)
#  custom          :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :library_location do
    name "Back of the Yards"
    zipcode "87654"
  end
end
