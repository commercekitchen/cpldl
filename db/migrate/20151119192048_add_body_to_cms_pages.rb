class AddBodyToCmsPages < ActiveRecord::Migration
  def change
    add_column :cms_pages, :body, :text
  end
end
