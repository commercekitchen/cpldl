class Attachment < ActiveRecord::Base
  belongs_to :course

  has_attached_file :document
  validates_attachment_content_type :document, content_type: ["application/pdf", "text/plain"],
                                                    message: ", Only PDF files are allowed."

  # before_destroy :delete_associated_files
end
