class RemoveLastNameFromProfile < ActiveRecord::Migration[4.2]
  def change
    remove_column :profiles, :last_name, :string
  end
end
