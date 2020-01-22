class SubsiteAdminPolicy < ApplicationPolicy
  def show?
    subsite_admin?(organization)
  end

  def create?
    subsite_admin?(organization)
  end

  def destroy?
    subsite_admin?(organization)
  end

  def update?
    subsite_admin?(organization)
  end

  class Scope < Scope
    def resolve
      raise Pundit::NotAuthorizedError unless user.admin?
      association_name = scope.name.pluralize.underscore
      user.organization.send(association_name)
    end
  end

  protected

  def organization
    record.organization
  end
end
