class AddFileDescriptionToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :file_description, :string
  end
end
