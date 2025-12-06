class BackfillStorylineSlug < ActiveRecord::Migration[5.2]
  def up
    Lesson.find_each do |lesson|
      next if lesson.story_line_slug.present?
      next unless lesson.respond_to?(:story_line_file_name)
      next if lesson.story_line_file_name.blank?

      slug = lesson.story_line_file_name.sub(/\.zip\z/, '')
      lesson.update_columns(story_line_slug: slug) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
