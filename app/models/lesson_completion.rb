# frozen_string_literal: true

class LessonCompletion < ApplicationRecord
  belongs_to :course_progress
  belongs_to :lesson

  after_save :update_course_progress

  def update_course_progress
    course_progress.update(completed_at: Time.zone.now) if lesson.is_assessment?
  end
end
