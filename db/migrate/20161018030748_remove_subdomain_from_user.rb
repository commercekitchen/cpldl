class RemoveSubdomainFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :subdomain
  end
end
