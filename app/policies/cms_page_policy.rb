# frozen_string_literal: true

class CmsPagePolicy < AdminOnlyPolicy
  def show?
    record.organization == user.organization
  end
end
