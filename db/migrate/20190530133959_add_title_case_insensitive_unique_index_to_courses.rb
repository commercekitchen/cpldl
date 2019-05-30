class AddTitleCaseInsensitiveUniqueIndexToCourses < ActiveRecord::Migration
  def change
    enable_extension 'citext'
    change_column :courses, :title, :citext
  end
end
