class AddTitleUniqueIndexToCmsPages < ActiveRecord::Migration[4.2]
  def change
    add_index :cms_pages, [:title, :organization_id], unique: true
  end
end
