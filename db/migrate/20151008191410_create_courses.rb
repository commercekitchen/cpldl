class CreateCourses < ActiveRecord::Migration[4.2]
  def change
    create_table :courses do |t|
      t.string  :title, limit: 90
      t.string  :seo_page_title, limit: 90
      t.string  :meta_desc, limit: 156
      t.string  :summary, limit: 156
      t.text    :description
      t.string  :contributor
      t.string  :pub_status, limit: 2

      t.timestamps null: false
    end
  end
end
