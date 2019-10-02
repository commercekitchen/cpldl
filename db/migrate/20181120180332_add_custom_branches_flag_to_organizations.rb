class AddCustomBranchesFlagToOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :accepts_custom_branches, :boolean, default: false
  end
end
