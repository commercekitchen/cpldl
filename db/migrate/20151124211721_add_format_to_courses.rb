class AddFormatToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :format, :string
  end
end
