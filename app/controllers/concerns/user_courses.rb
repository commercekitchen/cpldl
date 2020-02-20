# frozen_string_literal: true

module UserCourses
  extend ActiveSupport::Concern

  def authorized_courses
    courses = Course.includes(:lessons)
                    .where(pub_status: 'P', language_id: current_language_id, organization: current_organization)
    courses = courses.everyone unless user_signed_in?
    courses
  end

  def current_language_id
    english_id = Language.find_by(name: 'English').id || 1
    spanish_id = Language.find_by(name: 'Spanish').id || 2

    I18n.locale == :es ? spanish_id : english_id
  end
end
