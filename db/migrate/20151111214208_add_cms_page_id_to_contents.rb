class AddCmsPageIdToContents < ActiveRecord::Migration[4.2]
  def change
    add_column :contents, :cms_page_id, :integer
    add_column :contents, :course_id,   :integer
    add_column :contents, :lesson_id,   :integer
  end
end
