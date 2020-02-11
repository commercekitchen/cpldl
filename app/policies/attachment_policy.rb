# frozen_string_literal: true

class AttachmentPolicy < AdminOnlyPolicy
  private

  def organization
    record.course.organization
  end
end
