# == Schema Information
#
# Table name: lessons
#
#  id                      :integer          not null, primary key
#  lesson_order            :integer
#  title                   :string(90)
#  duration                :integer
#  course_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string
#  summary                 :string(156)
#  story_line              :string(156)
#  seo_page_title          :string(90)
#  meta_desc               :string(156)
#  is_assessment           :boolean
#  story_line_file_name    :string
#  story_line_content_type :string
#  story_line_file_size    :integer
#  story_line_updated_at   :datetime
#

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
