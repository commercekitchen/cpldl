# frozen_string_literal: true

class LessonCompletion < ApplicationRecord
  belongs_to :course_progress
  belongs_to :lesson

  after_save :update_course_progress

  def update_course_progress
    return if course_progress.completed_at.present?
    return unless course_progress.all_lessons_completed?

    course_progress.update(completed_at: Time.zone.now)
  end
end
