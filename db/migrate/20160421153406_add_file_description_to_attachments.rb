class AddFileDescriptionToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :file_description, :string
  end
end
