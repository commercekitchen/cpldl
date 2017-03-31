class AddQuizResponsesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :quiz_responses, :text
  end
end
