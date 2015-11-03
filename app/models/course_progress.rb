class CourseProgress < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :completed_lessons, dependent: :destroy

  def complete?
    return true if completed_at.present?
    false
  end

  def percent_complete
    total = course.lessons.count
    completed = lessons_completed
    return 0 if total == 0
    percent = (completed.to_f / total) * 100
    percent.round
  end

  def lessons_completed
    completed_lessons.count
  end

  def next_lesson_id
    fail StandardError, "There are no available lessons for this course." if course.lessons.count == 0
    course.next_lesson_id(last_completed_lesson_id_by_order)
  end

  def last_completed_lesson_id_by_order
    # TODO: This is an N+1 query, it needs to be done better
    last_completed_lesson_order = 0
    completed_lessons.each do |l|
      lesson_order = course.lessons.find(l.lesson_id).lesson_order
      last_completed_lesson_order = lesson_order if lesson_order >= last_completed_lesson_order
    end
    if last_completed_lesson_order > 0
      course.lessons.find_by_lesson_order(last_completed_lesson_order).id
    else
      return 0
    end
  end
end
