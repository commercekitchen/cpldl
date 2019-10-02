class AddProgramLocationReferenceToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :program_location, index: true, foreign_key: true
  end
end
