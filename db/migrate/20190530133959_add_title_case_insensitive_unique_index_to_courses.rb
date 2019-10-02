class AddTitleCaseInsensitiveUniqueIndexToCourses < ActiveRecord::Migration[4.2]
  def change
    # NOTICE: Enable below line for local only. This will throw permission error on stagibg & prod. 
    # enable_extension 'citext'
    change_column :courses, :title, :citext
  end
end
