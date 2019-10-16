# frozen_string_literal: true

# == Schema Information
#
# Table name: programs
#
#  id                :integer          not null, primary key
#  program_name      :string
#  location_required :boolean          default(FALSE)
#  organization_id   :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  parent_type       :integer
#

FactoryBot.define do
  factory :program do
    program_name Faker::App.name
    location_required false
    parent_type Program.parent_types['seniors']
    organization

    trait :student_program do
      parent_type Program.parent_types['students_and_parents']
    end

    trait :young_adult_program do
      parent_type Program.parent_types['young_adults']
    end

    trait :location_required do
      location_required true
    end
  end
end
