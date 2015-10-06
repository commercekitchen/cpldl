class AddProfileToUser < ActiveRecord::Migration
  def change
    add_column :users, :profile_id, :integer
  end
end
