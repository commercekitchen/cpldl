# frozen_string_literal: true

module CourseCompletionHelper
  def course_completion_date(user, course)
    completion_date = user.present? ? user.course_progresses.find_by(course_id: course.id).completed_at : Time.zone.now
    local_time(completion_date, :date_only)
  end

  def certificate_user_identifier(user)
    return nil if user.blank?

    user.full_name.presence ||
      (user.phone_number.present? && number_to_phone(user.phone_number, area_code: true)) ||
      user.email
  end

  def course_time_spent(course)
    total_seconds = course.lessons.sum(:duration).to_i
    return nil unless total_seconds.positive?

    total_minutes = total_seconds / 60
    hours = total_minutes / 60
    minutes = total_minutes % 60

    parts = []
    parts << pluralize(hours, 'hr') if hours.positive?
    parts << pluralize(minutes, 'min') if minutes.positive? || parts.empty?
    parts.join(' ')
  end

  def certificate_brand_color(organization, attribute, fallback)
    organization&.public_send(attribute).presence || fallback
  end
end
