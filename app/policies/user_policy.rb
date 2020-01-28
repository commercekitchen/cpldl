# frozen_string_literal: true

class UserPolicy < AdminOnlyPolicy
  def show?
    record == user || subsite_admin?(organization)
  end

  def update?
    record == user || subsite_admin?(organization)
  end

  def confirm?
    subsite_admin?(organization) || trainer?(organization)
  end

  class Scope < Scope
    def resolve
      raise Pundit::NotAuthorizedError unless user.admin? || user.trainer?

      user.organization.users
    end
  end
end
