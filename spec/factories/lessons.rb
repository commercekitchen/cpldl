# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    course
    sequence :title do |n|
      "Lesson #{n}"
    end
    summary { 'Lesson summary' }
    duration { 90 }
    lesson_order { 1 }
    story_line { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip'), 'application/zip') }
  end

  factory :lesson_without_story, class: Lesson do
    course
    title { 'Lesson without story' }
    summary { 'Lesson summary' }
    duration { 90 }
    lesson_order { 1 }
  end
end
