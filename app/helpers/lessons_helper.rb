module LessonsHelper
  def asl_iframe(lesson)
    if lesson.story_line_file_name
      directory = lesson.story_line_file_name.chomp(".zip")
      story_line_url = "/storylines/#{lesson.id}/#{directory}/story.html"
      content_tag(:iframe, nil, src: "#{story_line_url}", class: "story_line")
    else
      content_tag(:p, "No lesson available at this point.", class: "note")
    end
  end
end
