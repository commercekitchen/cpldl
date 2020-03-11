# frozen_string_literal: true

class CoursePropagationService

  def initialize(course:)
    @course = course
  end

  def propagate_course_changes
    child_courses.each do |child|
      child.update(updated_course_attributes)
      # Update attachments
    end
  end

  private

  def child_courses
    Course.copied_from_course(@course)
  end

  def updated_course_attributes
    @course.attributes.slice(*attributes_to_propagate.map(&:to_s)).merge(category_name: @course.category&.name)
  end

  def attributes_to_propagate
    %i[title
       contributor
       summary
       description
       notes
       language_id
       format
       level
       seo_page_title
       meta_desc]
  end
end
