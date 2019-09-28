class AddIndexToOrganizationPreferences < ActiveRecord::Migration[4.2]
  def change
    change_column :organizations, :preferences, :jsonb, default: {}, null: false
    add_index :organizations, :preferences, using: :gin
  end
end
