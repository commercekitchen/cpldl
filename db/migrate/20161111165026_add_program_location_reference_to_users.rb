class AddProgramLocationReferenceToUsers < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :program_location, index: true, foreign_key: true
  end
end
