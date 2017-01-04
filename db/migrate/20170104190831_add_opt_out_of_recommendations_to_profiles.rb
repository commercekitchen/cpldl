class AddOptOutOfRecommendationsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :opt_out_of_recommendations, :boolean, default: :false
  end
end
