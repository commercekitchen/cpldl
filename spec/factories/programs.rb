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
    location_required false
    student_program false
    organization

    trait :student_program do
      student_program true
    end

    trait :location_required do
      location_required true
      location_field_name Faker::Hipster.word
    end
  end
end
