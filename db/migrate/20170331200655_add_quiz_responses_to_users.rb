class AddQuizResponsesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :quiz_responses_object, :text
  end
end
