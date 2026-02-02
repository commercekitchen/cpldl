class AddUnzipStatusesToLessons < ActiveRecord::Migration[5.2]
  def change
    add_column :lessons, :storyline_unzip_error, :string
    add_column :lessons, :storyline_unzip_failed_at, :datetime
    add_column :lessons, :storyline_unzip_status, :integer, null: true
    add_index  :lessons, :storyline_unzip_status
  end
end
