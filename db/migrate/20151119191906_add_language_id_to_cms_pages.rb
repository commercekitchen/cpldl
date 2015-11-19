class AddLanguageIdToCmsPages < ActiveRecord::Migration
  def change
    add_column :cms_pages, :language_id, :integer
  end
end
