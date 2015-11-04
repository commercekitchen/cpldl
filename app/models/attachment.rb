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
#

class Attachment < ActiveRecord::Base
  belongs_to :course

  has_attached_file :document
  validates_attachment_content_type :document, content_type: ["application/pdf", "text/plain"],
                                                    message: ", Only PDF files are allowed."
end
