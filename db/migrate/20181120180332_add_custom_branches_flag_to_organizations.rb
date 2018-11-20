class AddCustomBranchesFlagToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :accepts_custom_branches, :boolean, default: false
  end
end
