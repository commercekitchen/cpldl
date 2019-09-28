class RemoveContentFromPages < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_pages, :content, :text
  end
end
