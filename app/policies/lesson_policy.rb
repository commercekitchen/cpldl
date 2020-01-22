# frozen_string_literal: true

class LessonPolicy < AdminOnlyPolicy
  def show?
    course = record.course

    return false unless course.organization == user.organization
    return false unless course.published?

    if user.is_a?(GuestUser)
      course.everyone? && !course.organization.login_required?
    else
      true
    end
  end

  class Scope < Scope
    def resolve
      raise Pundit::NotAuthorizedError unless user.admin?

      user.organization.lessons
    end
  end

  private

  def organization
    record.course.organization
  end
end
