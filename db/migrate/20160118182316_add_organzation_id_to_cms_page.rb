class AddOrganzationIdToCmsPage < ActiveRecord::Migration
  def change
    add_column :cms_pages, :organization_id, :integer
  end
end
