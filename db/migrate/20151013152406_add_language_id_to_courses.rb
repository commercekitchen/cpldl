class AddLanguageIdToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :language_id, :integer
  end
end
