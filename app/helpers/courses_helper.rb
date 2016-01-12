# == Schema Information
#
# Table name: courses
#
#  id             :integer          not null, primary key
#  title          :string(90)
#  seo_page_title :string(90)
#  meta_desc      :string(156)
#  summary        :string(156)
#  description    :text
#  contributor    :string
#  pub_status     :string           default("D")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :integer
#  level          :string
#  notes          :text
#  slug           :string
#  course_order   :integer
#  pub_date       :datetime
#  format         :string
#

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

  def percent_complete(course)
    if user_signed_in?
      course_progress = current_user.course_progresses.find_by_course_id(course.id)
      if course_progress.present?
        return "#{course_progress.percent_complete}#{I18n.t 'lesson_page.percent_complete'}"
      else
        return "0#{I18n.t 'lesson_page.percent_complete'}"
      end
    end
    ""
  end
end
