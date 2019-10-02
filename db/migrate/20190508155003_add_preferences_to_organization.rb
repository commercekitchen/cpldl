class AddPreferencesToOrganization < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :preferences, :jsonb
  end
end
