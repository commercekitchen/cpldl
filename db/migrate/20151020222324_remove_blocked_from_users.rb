class RemoveBlockedFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :blocked?, :boolean
  end
end
