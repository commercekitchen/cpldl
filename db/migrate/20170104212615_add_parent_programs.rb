class AddParentPrograms < ActiveRecord::Migration[4.2]
  def change
    add_column :programs, :parent_type, :integer

    Program.reset_column_information

    Program.all.each do |p|
      p.parent_type = p.student_program ? 2 : 0
      p.save!
    end
  end
end
