# frozen_string_literal: true

FactoryBot.define do
  factory :program do
    program_name { Faker::Lorem.words(number: 4).join(' ') }
    location_required { false }
    parent_type { Program.parent_types['seniors'] }
    organization { create(:organization, :accepts_programs) }

    trait :student_program do
      parent_type { Program.parent_types['students_and_parents'] }
    end

    trait :young_adult_program do
      parent_type { Program.parent_types['young_adults'] }
    end

    trait :location_required do
      location_required { true }
    end
  end
end
