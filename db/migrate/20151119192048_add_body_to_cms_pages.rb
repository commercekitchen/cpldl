class AddBodyToCmsPages < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_pages, :body, :text
  end
end
