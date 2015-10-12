class Attachment < ActiveRecord::Base
  belongs_to :course

  has_attached_file :document, default_url: "/system/storage/documents/:id/:style/:basename.:extension"
  validates_attachment_content_type :document, content_type: "application/pdf",
                                                    message: ", Only PDF, WORD, or POWERPOINT files are allowed."
end
