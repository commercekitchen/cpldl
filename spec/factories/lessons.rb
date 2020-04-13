# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    sequence :title do |n|
      "Lesson #{n}"
    end
    summary 'Lesson summary'
    duration 90
    lesson_order 1
    story_line { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip'), 'application/zip') }
    course
  end

  factory :lesson_without_story, class: Lesson do
    title 'Lesson without story'
    summary 'Lesson summary'
    duration 90
    lesson_order 1
    course
  end
end
