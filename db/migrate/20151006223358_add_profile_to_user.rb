class AddProfileToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :profile_id, :integer
  end
end
