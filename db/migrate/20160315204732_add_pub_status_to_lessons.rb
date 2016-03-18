class AddPubStatusToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :pub_status, :string
  end
end
