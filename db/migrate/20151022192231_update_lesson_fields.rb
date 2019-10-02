class UpdateLessonFields < ActiveRecord::Migration
  def change
    add_column :lessons, :summary, :string, limit: 156
    add_column :lessons, :story_line, :string, limit: 156  #Note: this is temporary
    add_column :lessons, :seo_page_title, :string, limit: 90
    add_column :lessons, :meta_desc, :string, limit: 156
    add_column :lessons, :is_assessment, :boolean
    remove_column :lessons, :description, :string
  end
end
