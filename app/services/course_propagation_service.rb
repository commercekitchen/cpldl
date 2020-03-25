# frozen_string_literal: true

class CoursePropagationService

  def initialize(course:)
    @course = course
  end

  def propagate_course_changes(attributes_to_propagate)
    child_courses.each do |child|
      child.update(attributes_to_propagate.merge(topics: topics))
    end
  end

  private

  def child_courses
    Course.copied_from_course(@course)
  end

  def topics
    @course.topics
  end
end
