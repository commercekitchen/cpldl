class OrganizationPolicy < ApplicationPolicy
  def get_recommendations?
    record == user.organization
  end

  def update?
    record == user.organization && user.admin?
  end

  class Scope < Scope
    def resolve
      scope.all if user.admin?
    end
  end
end
