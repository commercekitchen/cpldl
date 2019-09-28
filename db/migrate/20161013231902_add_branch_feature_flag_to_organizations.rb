class AddBranchFeatureFlagToOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :branches, :boolean
  end
end
