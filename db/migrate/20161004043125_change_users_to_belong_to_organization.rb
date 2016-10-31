class ChangeUsersToBelongToOrganization < ActiveRecord::Migration
  def change
    add_reference :users, :organization, index: true
    add_foreign_key :users, :organizations

    User.all.each do |user|
      user.organization = user.roles.find_by_resource_type("Organization").resource
      unless user.save
        puts "#{user.id} did not save"
      end
    end
  end
end
