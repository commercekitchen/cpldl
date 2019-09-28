class RemovePageTypeFromCmsPages < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_pages, :page_type
  end
end
