class AddAsMigrationTimestamps < ActiveRecord::Migration[5.2]
  def change
    add_column :attachments, :migrated_to_active_storage_at, :datetime
    add_column :ckeditor_attets, :migrated_to_active_storage_at, :datetime
  end
end
