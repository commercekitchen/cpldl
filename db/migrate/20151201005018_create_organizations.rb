class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :subdomain
      t.timestamps null: false
    end
  end
end
