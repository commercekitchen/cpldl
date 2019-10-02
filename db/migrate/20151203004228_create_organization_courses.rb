class CreateOrganizationCourses < ActiveRecord::Migration[4.2]
  def change
    create_table :organization_courses do |t|
      t.integer :organization_id
      t.integer :course_id
      t.timestamps null: false
    end
  end
end
