# frozen_string_literal: true

class CourseProgress < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :lesson_completions, dependent: :destroy
  has_many :completed_lessons, -> { order(:lesson_order) }, through: :lesson_completions, source: :lesson

  has_one :profile, through: :user

  scope :completed, -> { where('completed_at IS NOT NULL') }
  scope :tracked, -> { where(tracked: true) }
  scope :completed_with_profile, -> { joins(:user).joins(:profile).where.not(completed_at: nil) }

  def complete?
    return true if completed_at.present?

    false
  end

  def percent_complete
    total = course.lessons.count
    completed = lessons_completed
    return 0 if total.zero?

    percent = (completed.to_f / total) * 100
    percent = 100 if percent > 100
    percent.round
  end

  def lessons_completed
    completed_lessons.count
  end

  def next_lesson
    raise StandardError, 'There are no available lessons for this course.' if course.lessons.count.zero?

    course.lesson_after(completed_lessons.last)
  end
end
