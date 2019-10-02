class AddProgramIdToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :program_id, :integer
  end
end
