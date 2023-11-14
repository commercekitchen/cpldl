class AddMissingUuids < ActiveRecord::Migration[5.2]
  def up
    User.where(uuid: nil).each do |u|
      u.uuid = SecureRandom.uuid
      u.save(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
