class AddDisplayOnDlAttribute < ActiveRecord::Migration
  def change
    add_column :courses, :display_on_dl, :boolean, default: false
  end
end
