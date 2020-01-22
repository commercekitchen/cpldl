# frozen_string_literal: true

class OrganizationPolicy < AdminOnlyPolicy
  def get_recommendations?
    record == user.organization
  end

  def download_reports?
    admin_user?
  end

  def customize?
    admin_user?
  end

  def import_courses?
    admin_user?
  end

  def invite_user?
    admin_user?
  end

  class Scope < Scope
    def resolve
      www_subsite = Organization.find_by(subdomain: 'www')
      raise Pundit::NotAuthorizedError, 'must be a PLA admin' unless user.admin? && user.has_role?(:admin, www_subsite)

      scope.all
    end
  end

  private

  def organization
    record
  end
end
