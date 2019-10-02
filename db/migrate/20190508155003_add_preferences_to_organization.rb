class AddPreferencesToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :preferences, :jsonb
  end
end
