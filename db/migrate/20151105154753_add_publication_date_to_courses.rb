class AddPublicationDateToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :pub_date, :datetime
  end
end
