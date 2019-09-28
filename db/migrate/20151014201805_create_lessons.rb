class CreateLessons < ActiveRecord::Migration[4.2]
  def change
    create_table :lessons do |t|
      t.integer  :order
      t.string  :title, limit: 90
      t.text  :description
      t.integer  :duration
      t.integer :course_id
      t.timestamps null: false
    end
  end
end
