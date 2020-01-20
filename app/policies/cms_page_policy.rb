class CmsPagePolicy < ApplicationPolicy
  def show?
    matches_user_org?
  end

  def create?
    matches_user_org? && user.admin?
  end

  def update?
    matches_user_org? && user.admin?
  end

  def destroy?
    matches_user_org? && user.admin?
  end

  class Scope < Scope
    def resolve
      raise Pundit::NotAuthorizedError, "must be a subsite admin" unless user.admin?
      scope.where(organization: user.organization)
    end
  end

  private

    def matches_user_org?
      record.organization == user.organization
    end
end
