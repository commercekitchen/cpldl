class AddPublicationStatusEnumToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :publication_status, :integer, null: false, default: 0
  end
end
