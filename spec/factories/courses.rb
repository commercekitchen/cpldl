# frozen_string_literal: true

FactoryBot.define do

  factory :course do
    title { Faker::Lorem.characters(number: 25) }
    meta_desc 'A first course in computing'
    summary 'In this course you will...'
    description 'Description'
    contributor 'John Doe'
    level 'Beginner'
    format 'D'
    language
    organization
    pub_status 'P'

    factory :draft_course do
      pub_status 'D'
    end

    factory :archived_course do
      pub_status 'A'
    end

    factory :coming_soon_course do
      pub_status 'C'
    end

    factory :course_with_lessons do
      after(:create) do |course|
        create(:lesson, course: course, lesson_order: 1)
        create(:lesson, course: course, lesson_order: 2)
        create(:lesson, course: course, lesson_order: 3)
      end
    end
  end

end
