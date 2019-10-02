class CreateAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :attachments do |t|
      t.integer :course_id
      t.string :title

      t.timestamps null: false
    end
  end
end
