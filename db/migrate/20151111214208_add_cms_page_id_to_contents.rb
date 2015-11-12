class AddCmsPageIdToContents < ActiveRecord::Migration
  def change
    add_column :contents, :cms_page_id, :integer
  end
end
