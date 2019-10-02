class AddAttachmentDocumentToAttachments < ActiveRecord::Migration[4.2]
  def self.up
    change_table :attachments do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :attachments, :document
  end
end
