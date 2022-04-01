class AddSurveyUrlToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :survey_url, :string
  end
end
