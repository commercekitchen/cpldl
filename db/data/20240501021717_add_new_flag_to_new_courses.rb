class AddNewFlagToNewCourses < ActiveRecord::Migration[5.2]
  def up
    Course.where('title LIKE ? OR title LIKE ?', '%(New!)', '%(Nuevo)').update_all(new_course: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
