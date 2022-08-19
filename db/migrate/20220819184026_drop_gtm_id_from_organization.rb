class DropGtmIdFromOrganization < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :gtm_id, :string
  end
end
