class AddSchoolsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :school_id, :integer
  end
end
