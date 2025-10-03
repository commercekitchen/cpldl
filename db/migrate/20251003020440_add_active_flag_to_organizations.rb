class AddActiveFlagToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :active, :boolean, default: true, null: false
  end
end
