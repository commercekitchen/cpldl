# frozen_string_literal: true

class Attachment < ApplicationRecord
  belongs_to :course
  has_attached_file :document

  validates_attachment_content_type :document, content_type: ['application/pdf',
                                                              'text/plain',
                                                              'application/vnd.ms-excel',
                                                              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                                              'application/vnd.ms-powerpoint',
                                                              'application/vnd.openxmlformats-officedocument.presentationml.presentation',
                                                              'application/msword',
                                                              'application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
                                                    message: 'is invalid. Only PDF, Word, PowerPoint, or Excel files are allowed.'

  validates :doc_type, allow_blank: true,
                         inclusion: { in: %w[text-copy additional-resource],
                           message: '%<value>s is not a doc_type' }
end
