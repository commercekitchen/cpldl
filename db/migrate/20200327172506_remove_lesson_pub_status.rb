class RemoveLessonPubStatus < ActiveRecord::Migration[5.2]
  def change
    remove_column :lessons, :pub_status, :string, default: 'D'
  end
end
