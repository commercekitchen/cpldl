class AddSubsiteToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :subsite_course, :boolean, default: false
  end
end
