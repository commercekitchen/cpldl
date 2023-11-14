class AddUuidToUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :token, :uuid
  end
end
