class AddLanguageIdToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :language_id, :integer
  end
end
