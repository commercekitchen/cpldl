# frozen_string_literal: true

module LessonsHelper
  def asl_iframe(lesson)
    if lesson.parent
      lesson_id = lesson.parent_id
      directory = lesson.parent.story_line_file_name.chomp('.zip')
    elsif lesson.story_line_file_name
      lesson_id = lesson.id
      directory = lesson.story_line_file_name.chomp('.zip')
    end

    if directory.present?
      story_line_url = "/storylines/#{lesson_id}/#{directory}/story.html"
      content_tag(:iframe, nil, src: story_line_url.to_s, class: 'story_line', title: lesson.summary, id: 'asl-iframe')
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
