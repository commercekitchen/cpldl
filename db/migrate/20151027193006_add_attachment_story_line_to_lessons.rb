class AddAttachmentStoryLineToLessons < ActiveRecord::Migration[4.2]
  def self.up
    change_table :lessons do |t|
      t.attachment :story_line
    end
  end

  def self.down
    remove_attachment :lessons, :story_line
  end
end
