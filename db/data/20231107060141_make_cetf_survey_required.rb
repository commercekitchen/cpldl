class MakeCetfSurveyRequired < ActiveRecord::Migration[5.2]
  def up
    Organization.find_by(subdomain: 'getconnected').update!(survey_required: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
