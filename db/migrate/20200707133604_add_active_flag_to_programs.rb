class AddActiveFlagToPrograms < ActiveRecord::Migration[5.2]
  def change
    add_column :programs, :active, :boolean, default: true, null: false
  end
end
