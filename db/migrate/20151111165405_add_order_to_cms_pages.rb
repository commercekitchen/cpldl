class AddOrderToCmsPages < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_pages, :cms_page_order, :integer
  end
end
