class AddSchoolTypeToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :school_type, :int
    add_index :schools, :school_type
  end
end
