module CoursesHelper
  def current_topics(course, topic)
    titles = course.topics.map(&:title)
    titles.include?(topic.title)
  end

  def pub_status_str(course)
    case course.pub_status
    when "D" then "Draft"
    when "P" then "Published"
    when "T" then "Trashed"
    end
  end

  def percent_complete(course)
    if user_signed_in?
      course_progress = current_user.course_progresses.find_by_course_id(course.id)
      if course_progress.present?
        return "#{course_progress.percent_complete}% complete"
      else
        return "0% complete"
      end
    end
    ""
  end
end
