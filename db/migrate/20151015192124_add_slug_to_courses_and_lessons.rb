class AddSlugToCoursesAndLessons < ActiveRecord::Migration
  def change
    add_column :courses, :slug, :string
    add_index :courses, :slug

    add_column :lessons, :slug, :string
    add_index :lessons, :slug
  end
end
