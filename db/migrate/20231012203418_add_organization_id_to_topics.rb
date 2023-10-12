class AddOrganizationIdToTopics < ActiveRecord::Migration[5.2]
  def change
    add_reference :topics, :organization, index: true, foreign_key: true
  end
end
