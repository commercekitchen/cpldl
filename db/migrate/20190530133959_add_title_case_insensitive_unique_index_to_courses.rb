class AddTitleCaseInsensitiveUniqueIndexToCourses < ActiveRecord::Migration
  def change
    # NOTICE: Enable below line for local only. This will throw permission error on stagibg & prod. 
    # enable_extension 'citext'
    change_column :courses, :title, :citext
  end
end
