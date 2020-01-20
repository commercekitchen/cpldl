# frozen_string_literal: true

class CoursePolicy < ApplicationPolicy
  def show?
    return false unless record.organization == user.organization
    return false unless record.published?

    if user.is_a?(GuestUser)
      record.everyone?
    else
      true
    end
  end

  def track?
    return false if user.is_a?(GuestUser)

    record.organization == user.organization && record.published?
  end

  class Scope < Scope
    def resolve
      courses = scope.includes(:lessons).where(pub_status: 'P', organization: user.organization)

      if user.is_a? GuestUser
        courses.everyone
      else
        courses
      end
    end
  end
end
