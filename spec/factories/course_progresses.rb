# frozen_string_literal: true

FactoryBot.define do
  factory(:course_progress) do
    user
    course
  end
end
