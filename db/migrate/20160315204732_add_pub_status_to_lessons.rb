class AddPubStatusToLessons < ActiveRecord::Migration
  def self.up
    add_column :lessons, :pub_status, :string

    Lesson.all.each do |lesson|
      lesson.pub_status = "P"
      lesson.save
    end
  end

  def self.down
    remove_column :lessons, :pub_status, :string
  end
end
