class RemovePageTypeFromCmsPages < ActiveRecord::Migration
  def change
    remove_column :cms_pages, :page_type
  end
end
