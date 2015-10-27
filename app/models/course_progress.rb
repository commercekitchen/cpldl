class CourseProgress < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  def next_lesson
    total = course.lessons.count
    return 1 if lessons_completed.blank?
    return total if lessons_completed >= total
    lessons_completed + 1
  end

  def percent_complete
    total = course.lessons.count
    return 0 if lessons_completed.blank? || total == 0
    percent = (lessons_completed.to_f / total) * 100
    percent.round
  end
end
