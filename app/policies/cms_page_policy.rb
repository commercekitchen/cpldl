class CmsPagePolicy < SubsiteAdminPolicy
  def show?
    record.organization == user.organization
  end
end
