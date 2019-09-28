class RemoveCkEditorAssets < ActiveRecord::Migration[4.2]
  def change
    if ActiveRecord::Base.connection.table_exists? "ckeditor_assets"
      drop_table :ckeditor_assets
    end
  end
end
