class CleanUpDevise < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :confirmation_token, :string
    remove_column :users, :confirmed_at, :datetime
    remove_column :users, :confirmation_sent_at, :datetime
    remove_column :users, :unconfirmed_email, :string

    remove_column :users, :failed_attempts, :integer, default: 0, null: false
    remove_column :users, :unlock_token, :string
    remove_column :users, :locked_at, :datetime
  end
end
