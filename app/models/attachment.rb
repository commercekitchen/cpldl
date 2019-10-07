# == Schema Information
#
# Table name: attachments
#
#  id                    :integer          not null, primary key
#  course_id             :integer
#  title                 :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :integer
#  document_updated_at   :datetime
#  doc_type              :string
#  file_description      :string
#

class Attachment < ApplicationRecord
  belongs_to :course
  has_attached_file :document

  validates_attachment_content_type :document, content_type: ["application/pdf",
                                                              "text/plain",
                                                              "application/vnd.ms-excel",
                                                              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                                                              "application/vnd.ms-powerpoint",
                                                              "application/vnd.openxmlformats-officedocument.presentationml.presentation",
                                                              "application/msword",
                                                              "application/vnd.openxmlformats-officedocument.wordprocessingml.document"],
                                                    message: ", Only PDF, Word, PowerPoint, or Excel files are allowed."

  validates :doc_type, allow_blank: true,
                         inclusion: { in: %w(supplemental post-course),
                           message: "%{value} is not a doc_type" }
end
