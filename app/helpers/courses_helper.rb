module CoursesHelper
  def current_topics(course, topic)
    titles = course.topics.map { |t| t.title }
    titles.include?(topic.title)
  end
end
