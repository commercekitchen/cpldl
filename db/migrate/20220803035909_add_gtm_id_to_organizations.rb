class AddGtmIdToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :gtm_id, :string
  end
end
