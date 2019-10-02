class AddLanguageIdToProfile < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :language_id, :integer
  end
end
