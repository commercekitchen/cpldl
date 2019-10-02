class AddLanguageIdToCmsPages < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_pages, :language_id, :integer
  end
end
