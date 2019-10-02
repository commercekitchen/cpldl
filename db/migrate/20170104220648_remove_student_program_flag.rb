class RemoveStudentProgramFlag < ActiveRecord::Migration[4.2]
  def change
    remove_column :programs, :student_program, :boolean
  end
end
