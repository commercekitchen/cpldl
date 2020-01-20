class LibraryLocationPolicy < ApplicationPolicy
  def show?
    matches_user_org? && user.admin?
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
      scope.where(organization: user.organization)
    end
  end

  private

    def matches_user_org?
      record.organization == user.organization
    end
end
