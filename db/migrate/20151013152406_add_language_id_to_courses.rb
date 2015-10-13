class AddLanguageIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :language_id, :integer
  end
end
