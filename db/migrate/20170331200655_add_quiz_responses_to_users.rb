class AddQuizResponsesToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :quiz_responses_object, :text
  end
end
