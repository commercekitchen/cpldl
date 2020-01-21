class ProgramPolicy < ApplicationPolicy
  def create?
    user.admin? && record.organization == user.organization
  end

  def destroy?
    user.admin? && record.organization == user.organization
  end

  def update?
    user.admin? && record.organization == user.organization
  end

  class Scope < Scope
    def resolve
      raise Pundit::NotAuthorizedError unless user.admin?
      user.organization.programs
    end
  end
end
