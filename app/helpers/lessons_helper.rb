# frozen_string_literal: true

module LessonsHelper
  def asl_iframe(lesson)
    parent_or_self = lesson.parent || lesson
    entry_path = parent_or_self.storyline_entry_path

    if entry_path.present?
      story_line_url = "/#{entry_path}"
      content_tag(
        :iframe, nil,
        src: story_line_url,
        class: 'story_line',
        title: lesson.summary,
        id: 'asl-iframe'
      )
    else
      content_tag(:p, 'No lesson available at this point.', class: 'note')
    end
  end

  def lessons_completed(course)
    if user_signed_in?
      current_user.completed_lesson_ids(course)
    else
      (session[:completed_lessons] || []) & course.lessons.pluck(:id)
    end
  end
end
