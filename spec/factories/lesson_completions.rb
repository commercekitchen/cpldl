# frozen_string_literal: true

FactoryBot.define do
  factory(:lesson_completion) do
    course_progress
    lesson
  end
end
