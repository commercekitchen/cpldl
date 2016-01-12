class AddQuizModalComplete < ActiveRecord::Migration
  def change
    add_column :users, :quiz_modal_complete, :boolean, default: false
  end
end
