class ProgramLocationPolicy < SubsiteAdminPolicy
  private
    def organization
      record.program.organization
    end
end
