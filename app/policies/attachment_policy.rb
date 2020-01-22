class AttachmentPolicy < SubsiteAdminPolicy
  private

    def organization
      record.course.organization
    end
end
