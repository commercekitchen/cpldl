# frozen_string_literal: true

module CoursesHelper
  def current_topics(course, topic)
    titles = course.topics.map(&:title)
    titles.include?(topic.title)
  end

  def pub_status_str(course)
    case course.pub_status
    when 'D' then 'Draft'
    when 'P' then 'Published'
    when 'T' then 'Trashed'
    end
  end

  def percent_complete(course)
    if user_signed_in?
      course_progress = current_user.course_progresses.find_by(course_id: course.id)
      if course_progress.present?
        return "#{course_progress.percent_complete}#{I18n.t 'lesson_page.percent_complete'}"
      else
        return "0#{I18n.t 'lesson_page.percent_complete'}"
      end
    end
    ''
  end

  def percent_complete_without_user(course, _lesson_id)
    session[:completed_lessons] ||= []
    total_lessons = course.lessons.count
    completed = (session[:completed_lessons] & course.lessons.pluck(:id)).count
    return 0 if total_lessons.zero?

    percent = (completed.to_f / total_lessons) * 100
    percent = 100 if percent > 100
    percent.round
  end

  def courses_completed
    user_signed_in? ? current_user.completed_course_ids : []
  end

  def categorized_courses(courses)
    courses.group_by do |course|
      if course.category&.enabled?
        course.category.name
      else
        'Uncategorized'
      end
    end
  end

  def start_or_resume_course_link(course, preview = nil)
    return if course.lessons.empty?

    course_progress = current_user&.course_progresses&.find_by(course_id: course.id)

    lesson_path = if course_progress
                    course_lesson_path(course, course_progress.next_lesson, preview: preview)
                  else
                    course_lesson_path(course, course.lessons.first, preview: preview)
                  end

    link_to t('course_page.start_course').to_s, lesson_path, class: 'btn button-color', data: { cpl_ga_event: 'on', cpl_ga_value: 'user-start-course' }
  end
end
