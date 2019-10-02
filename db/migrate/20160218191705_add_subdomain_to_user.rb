class AddSubdomainToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :subdomain, :string
  end
end
