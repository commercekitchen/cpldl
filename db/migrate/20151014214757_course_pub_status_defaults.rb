class CoursePubStatusDefaults < ActiveRecord::Migration[4.2]
  def change
    change_column :courses, :pub_status, :string, default: "D"
  end
end
