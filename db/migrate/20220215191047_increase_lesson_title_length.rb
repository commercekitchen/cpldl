class IncreaseLessonTitleLength < ActiveRecord::Migration[5.2]
  def change
    change_column :lessons, :title, :string, length: 100
  end
end
