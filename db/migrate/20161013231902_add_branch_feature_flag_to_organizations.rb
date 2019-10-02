class AddBranchFeatureFlagToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :branches, :boolean
  end
end
