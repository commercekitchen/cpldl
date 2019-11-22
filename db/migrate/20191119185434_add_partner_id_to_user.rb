class AddPartnerIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :partner, index: true, foreign_key: true
  end
end
