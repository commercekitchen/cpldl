class AddPublicationDateToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :pub_date, :datetime
  end
end
