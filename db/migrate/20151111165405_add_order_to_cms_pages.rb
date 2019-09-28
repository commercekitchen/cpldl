class AddOrderToCmsPages < ActiveRecord::Migration
  def change
    add_column :cms_pages, :cms_page_order, :integer
  end
end
