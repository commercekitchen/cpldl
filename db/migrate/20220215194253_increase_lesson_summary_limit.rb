class IncreaseLessonSummaryLimit < ActiveRecord::Migration[5.2]
  def change
    change_column :lessons, :summary, :string, length: 255
  end
end
