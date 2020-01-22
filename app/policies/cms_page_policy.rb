# frozen_string_literal: true

class CmsPagePolicy < SubsiteAdminPolicy
  def show?
    record.organization == user.organization
  end
end
