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

  def create?
    user.admin? && user.organization == record.organization
  end

  def update?
    user.admin? && user.organization == record.organization
  end

  def destroy?
    user.admin? && user.organization == record.organization
  end

  class Scope < Scope
    def resolve
      courses = scope.includes(:lessons).where(organization: user.organization)

      if user.is_a? GuestUser
        courses.published.everyone
      elsif user.admin?
        courses.where.not(pub_status: 'A')
      else
        courses.published
      end
    end
  end
end
