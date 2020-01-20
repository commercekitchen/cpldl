class OrganizationPolicy < ApplicationPolicy
  def get_recommendations?
    matches_user_org?
  end

  def update?
    matches_user_org? && user.admin?
  end

  def customize?
    matches_user_org? && user.admin?
  end

  def import_courses?
    matches_user_org? && user.admin?
  end

  class Scope < Scope
    def resolve
      www_subsite = Organization.find_by(subdomain: 'www')
      raise Pundit::NotAuthorizedError, "must be a PLA admin" unless user.admin? && user.has_role?(:admin, www_subsite)
      scope.all
    end
  end

  private

  def matches_user_org?
    record == user.organization
  end
end
