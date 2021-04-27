# frozen_string_literal: true

module CourseCompletionHelper
  def course_completion_date(user, course)
    completion_date = user.present? ? user.course_progresses.find_by(course_id: course.id).completed_at : Time.zone.now
    local_time(completion_date, :date_only)
  end
end
