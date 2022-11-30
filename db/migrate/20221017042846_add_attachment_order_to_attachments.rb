class AddAttachmentOrderToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :attachments, :attachment_order, :integer, default: 0
  end
end
