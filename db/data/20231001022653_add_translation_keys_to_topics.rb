class AddTranslationKeysToTopics < ActiveRecord::Migration[5.2]
  def up
    Topic.all.each do |topic|
      topic.update(translation_key: topic.title.parameterize(separator: '_'))
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
