# frozen_string_literal: true

class AdminOnlyPolicy < ApplicationPolicy
  def show?
    admin_user?
  end

  def index?
    admin_user?(any_organization: true)
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

  def sort?
    # These should be protected by scopes
    admin_user?(any_organization: true)
  end

  class Scope < Scope
    def resolve
      raise Pundit::NotAuthorizedError unless user.admin?

      association_name = scope.name.pluralize.underscore
      user.organization.send(association_name)
    end
  end

  protected

  def admin_user?(any_organization: false)
    if any_organization
      user.admin?
    else
      subsite_admin?(organization)
    end
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
