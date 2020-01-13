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
    total_lessons = course.lessons.published.count
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
    category_map = {}

    (categories || []).each do |category|
      category_courses = courses.with_category(category.id)

      if category_courses.present?
        category_map[category.name] = category_courses
      end
    end

    disabled_category_courses = courses.where(category_id: current_organization.categories.disabled.map(&:id))
    uncategorized_courses = courses.where(category_id: nil) + disabled_category_courses

    if uncategorized_courses.present?
      category_map['Uncategorized'] = uncategorized_courses
    end

    category_map
  end

  private

  def categories
    current_organization.categories.enabled
  end
end
