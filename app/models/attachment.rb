# frozen_string_literal: true

class Attachment < ApplicationRecord
  belongs_to :course
  has_attached_file :document
  has_one_attached :document_file

  ALLOWED_TYPES = [
    "application/pdf",
    "text/plain",
    "application/vnd.ms-excel",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/vnd.ms-powerpoint",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ].freeze

  validate :document_file_content_type

  validates :doc_type, allow_blank: true,
                         inclusion: { in: %w[text-copy additional-resource],
                           message: '%<value>s is not a doc_type' }

  def document_file_content_type
    return unless document_file.attached?
    unless ALLOWED_TYPES.include?(document_file.blob.content_type)
      errors.add(:document_file, "is invalid. Only PDF, Word, PowerPoint, or Excel files are allowed.")
    end
  end
end
