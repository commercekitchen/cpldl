class RemoveSubsiteCourseFlag < ActiveRecord::Migration[5.2]
  def change
    remove_column :courses, :subsite_course, :boolean, default: false
  end
end
