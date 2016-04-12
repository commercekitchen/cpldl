class AddTokenToUser < ActiveRecord::Migration
  require "securerandom"

  def self.up
    add_column :users, :token, :string

    User.all.each do |user|
      user.token = SecureRandom.uuid
      user.save
    end
  end

  def self.down
    remove_column :users, :token, :string
  end
end
