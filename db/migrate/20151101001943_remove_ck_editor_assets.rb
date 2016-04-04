class RemoveCkEditorAssets < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists? "ckeditor_assets"
      drop_table :ckeditor_assets
    end
  end
end
