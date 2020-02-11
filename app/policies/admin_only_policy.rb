# frozen_string_literal: true

class AdminOnlyPolicy < ApplicationPolicy
  def show?
    admin_user?
  end

  def create?
    admin_user?
  end

  def destroy?
    admin_user?
  end

  def update?
    admin_user?
  end

  class Scope < Scope
    def resolve
      raise Pundit::NotAuthorizedError unless user.admin?

      association_name = scope.name.pluralize.underscore
      user.organization.send(association_name)
    end
  end

  protected

  def admin_user?
    subsite_admin?(organization)
  end

  def organization
    record.organization
  end

  def subsite_admin?(subsite)
    user.admin? && user.organization == subsite
  end

  def trainer?(subsite)
    user.trainer? && user.organization == subsite
  end
end
