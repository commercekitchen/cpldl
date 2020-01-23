# frozen_string_literal: true

class ProgramLocationPolicy < AdminOnlyPolicy
  private

  def organization
    record.program.organization
  end
end
