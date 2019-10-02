class AddTitleUniqueIndexToCmsPages < ActiveRecord::Migration
  def change
    add_index :cms_pages, [:title, :organization_id], unique: true
  end
end
