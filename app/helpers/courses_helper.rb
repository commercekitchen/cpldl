module CoursesHelper
  def current_topics(course, topic)
    titles = course.topics.map(&:title)
    titles.include?(topic.title)
  end

  def humanize_pub_status(course)
    case course.pub_status
    when "D" then "Draft"
    when "P" then "Published"
    when "T" then "Trashed"
    end
  end
end
