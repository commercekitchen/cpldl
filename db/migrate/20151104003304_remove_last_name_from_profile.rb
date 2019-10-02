class RemoveLastNameFromProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, :last_name, :string
  end
end
