class OrganizationPolicy < ApplicationPolicy
  def get_recommendations?
    record == user.organization
  end

  def download_reports?
    subsite_admin?(record)
  end

  def update?
    subsite_admin?(record)
  end

  def customize?
    subsite_admin?(record)
  end

  def import_courses?
    subsite_admin?(record)
  end

  class Scope < Scope
    def resolve
      www_subsite = Organization.find_by(subdomain: 'www')
      raise Pundit::NotAuthorizedError, "must be a PLA admin" unless user.admin? && user.has_role?(:admin, www_subsite)
      scope.all
    end
  end
end
