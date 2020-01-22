# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    record == user || subsite_admin?(record.organization)
  end

  def update?
    record == user || subsite_admin?(record.organization)
  end

  def confirm?
    user.is_a?(User) && (subsite_admin?(record.organization) || user.has_role?(:trainer, record.organization))
  end

  class Scope < Scope
    def resolve
      raise Pundit::NotAuthorizedError unless user.admin? || user.trainer?
      user.organization.users
    end
  end

  private

    def admin_at_org?
      user.is_a?(User) && user.has_role?(:admin, record.organization)
    end
end
