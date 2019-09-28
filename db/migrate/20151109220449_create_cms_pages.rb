class CreateCmsPages < ActiveRecord::Migration[4.2]
  def change
    create_table :cms_pages do |t|
      t.string   :title, limit: 90
      t.string   :author
      t.string   :page_type
      t.string   :audience
      t.text     :content
      t.string   :pub_status, default: "D"
      t.datetime :pub_date
      t.string   :seo_page_title, limit: 90
      t.string   :meta_desc, limit: 156

      t.timestamps null: false
    end
  end
end
