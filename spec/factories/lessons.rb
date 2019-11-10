# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    title 'Lesson 1'
    summary 'Lesson summary'
    duration 90
    lesson_order 1
    pub_status 'P'
    story_line { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip'), 'application/zip') }
    course
  end

  factory :lesson_without_story, class: Lesson do
    title 'Lesson without story'
    summary 'Lesson summary'
    pub_status 'P'
    duration 90
    lesson_order 1
    course
  end
end
