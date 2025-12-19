class AddUnzipErrorsToLessons < ActiveRecord::Migration[5.2]
  def change
    add_column :lessons, :unzip_failed_at, :datetime
    add_column :lessons, :unzip_error, :text
  end
end
