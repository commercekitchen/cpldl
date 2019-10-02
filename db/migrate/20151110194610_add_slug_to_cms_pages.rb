class AddSlugToCmsPages < ActiveRecord::Migration
  def change
    add_column :cms_pages, :slug, :string
    add_index :cms_pages, :slug
  end
end
