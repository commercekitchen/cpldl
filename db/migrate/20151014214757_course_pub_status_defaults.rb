class CoursePubStatusDefaults < ActiveRecord::Migration
  def change
    change_column :courses, :pub_status, :string, default: "D"
  end
end
