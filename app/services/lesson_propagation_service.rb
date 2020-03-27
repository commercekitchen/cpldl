# frozen_string_literal: true

class LessonPropagationService
  def initialize(lesson:)
    @lesson = lesson
  end

  def add_to_course!(course)
    new_lesson = @lesson.dup
    new_lesson.parent_id = @lesson.id
    new_lesson.course_id = course.id
    new_lesson.story_line = nil
    new_lesson.save!
  end

  def update_children!
    Lesson.copied_from_lesson(@lesson).each do |child|
      child.update!(@lesson.attributes.except('id', 'parent_id', 'course_id'))
    end
  end
end
