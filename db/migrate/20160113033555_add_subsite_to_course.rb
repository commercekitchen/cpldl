class AddSubsiteToCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :subsite_course, :boolean, default: false
  end
end
