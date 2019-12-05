# frozen_string_literal: true

class CourseProgress < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :completed_lessons, dependent: :destroy

  has_one :profile, through: :user

  scope :completed, -> { where('completed_at IS NOT NULL') }
  scope :tracked, -> { where(tracked: true) }
  scope :completed_with_profile, -> { joins(:user).joins(:profile).where.not(completed_at: nil) }

  def complete?
    return true if completed_at.present?

    false
  end

  def percent_complete
    total = course.lessons.published.count
    completed = lessons_completed
    return 0 if total.zero?

    percent = (completed.to_f / total) * 100
    percent = 100 if percent > 100
    percent.round
  end

  def lessons_completed
    completed_lessons.count
  end

  def next_lesson_id
    raise StandardError, 'There are no available lessons for this course.' if course.lessons.count.zero?

    course.next_lesson_id(last_completed_lesson_id_by_order)
  end

  def last_completed_lesson_id_by_order
    # TODO: This is an N+1 query, it needs to be done better
    last_completed_lesson_order = 0
    completed_lessons.each do |l|
      lesson_order = course.lessons.find(l.lesson_id).lesson_order
      last_completed_lesson_order = lesson_order if lesson_order >= last_completed_lesson_order
    end
    if last_completed_lesson_order.positive?
      course.lessons.find_by(lesson_order: last_completed_lesson_order).id
    else
      return 0
    end
  end
end
