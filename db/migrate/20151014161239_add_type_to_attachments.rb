class AddTypeToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :doc_type, :string
  end
end
