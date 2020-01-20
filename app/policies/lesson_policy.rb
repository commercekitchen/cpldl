# frozen_string_literal: true

class LessonPolicy < ApplicationPolicy
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

  def create?
    user.admin? && record.course.organization == user.organization
  end

  def update?
    user.admin? && record.course.organization == user.organization
  end
end
