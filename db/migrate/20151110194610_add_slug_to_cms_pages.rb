class AddSlugToCmsPages < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_pages, :slug, :string
    add_index :cms_pages, :slug
  end
end
