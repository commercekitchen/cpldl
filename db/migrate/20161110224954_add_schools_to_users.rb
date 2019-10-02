class AddSchoolsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :school_id, :integer
  end
end
