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

  def course_topics(course)
    topics = course.topics.map(&:title)
    return topics.join(", ")
  end
end
