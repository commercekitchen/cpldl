class AddTitleCaseInsensitiveUniqueIndexToCourses < ActiveRecord::Migration[4.2]
  def change
    # NOTICE: Enable extension locally only.
    # This will throw permission error on staging & prod. 
    if Rails.env.development? || Rails.env.test?
      enable_extension 'citext'
      change_column :courses, :title, :citext
    end
  end
end
