class AddQuizModalComplete < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :quiz_modal_complete, :boolean, default: false
  end
end
