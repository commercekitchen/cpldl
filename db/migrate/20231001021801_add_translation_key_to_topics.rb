class AddTranslationKeyToTopics < ActiveRecord::Migration[5.2]
  def change
    add_column :topics, :translation_key, :string
  end
end
