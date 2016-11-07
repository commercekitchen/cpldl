class AddSchoolsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :school_id, :integer
  end
end
