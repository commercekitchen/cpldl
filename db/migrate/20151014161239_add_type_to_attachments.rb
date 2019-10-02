class AddTypeToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :doc_type, :string
  end
end
