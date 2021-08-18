# frozen_string_literal: true

FactoryBot.define do

  factory :course do
    title { Faker::Lorem.characters(number: 25) }
    meta_desc { 'A first course in computing' }
    summary { 'In this course you will...' }
    description { 'Description' }
    contributor { 'John Doe' }
    level { 'Beginner' }
    format { 'D' }
    language
    organization
    publication_status { :published }

    trait :published do
      publication_status :published
    end

    trait :draft do
      publication_status :draft
    end

    trait :archived do
      publication_status :archived
    end

    trait :coming_soon do
      publication_status :draft
      coming_soon { true }
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
