class AddIndexToOrganizationPreferences < ActiveRecord::Migration
  def change
    change_column :organizations, :preferences, :jsonb, default: {}, null: false
    add_index :organizations, :preferences, using: :gin
  end
end
