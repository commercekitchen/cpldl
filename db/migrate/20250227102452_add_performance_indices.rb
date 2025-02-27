class AddPerformanceIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :course_progresses, :completed_at
    add_index :users, [:email, :library_card_number]
  end
end
