class AddOptOutOfRecommendationsToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :opt_out_of_recommendations, :boolean, default: false
  end
end
