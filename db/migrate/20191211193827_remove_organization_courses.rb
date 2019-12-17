class RemoveOrganizationCourses < ActiveRecord::Migration[5.2]
  def change
    drop_table :organization_courses
  end
end
