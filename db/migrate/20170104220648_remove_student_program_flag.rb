class RemoveStudentProgramFlag < ActiveRecord::Migration
  def change
    remove_column :programs, :student_program, :boolean
  end
end
