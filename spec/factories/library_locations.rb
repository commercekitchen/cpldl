# frozen_string_literal: true

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

FactoryBot.define do
  factory :library_location do
    name { Faker::Lorem.words(number: 2).join(' ') }
    zipcode '87654'
    organization
  end
end
