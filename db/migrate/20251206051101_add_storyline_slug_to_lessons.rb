class AddStorylineSlugToLessons < ActiveRecord::Migration[5.2]
  def change
    add_column :lessons, :story_line_slug, :string
    add_index  :lessons, :story_line_slug
  end
end
