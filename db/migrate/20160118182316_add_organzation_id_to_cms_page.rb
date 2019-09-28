class AddOrganzationIdToCmsPage < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_pages, :organization_id, :integer
  end
end
