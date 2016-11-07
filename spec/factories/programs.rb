# == Schema Information
#
# Table name: programs
#
#  id                  :integer          not null, primary key
#  program_name        :string
#  location_field_name :string
#  location_required   :boolean          default(FALSE)
#  student_program     :boolean          default(FALSE)
#  organization_id     :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

FactoryGirl.define do
  factory :program do
    program_name Faker::App.name
    organization
  end
end
