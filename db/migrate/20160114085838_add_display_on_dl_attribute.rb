class AddDisplayOnDlAttribute < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :display_on_dl, :boolean, default: false
  end
end
