# frozen_string_literal: true

# == Schema Information
#
# Table name: completed_lessons
#
#  id                 :integer          not null, primary key
#  course_progress_id :integer
#  lesson_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryBot.define do
  factory(:completed_lesson) do
    course_progress
  end
end
