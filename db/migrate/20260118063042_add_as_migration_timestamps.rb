class AddAsMigrationTimestamps < ActiveRecord::Migration[5.2]
  def change
    add_column :lessons, :migrated_to_active_storage_at, :datetime
    add_column :attachments, :migrated_to_active_storage_at, :datetime
    add_column :ckeditor_assets, :migrated_to_active_storage_at, :datetime
  end
end
