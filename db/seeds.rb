# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
Organization.create(name: "Chicago Public Library", subdomain: "chipublib")
admin_user = User.create(email: "admin@commercekitchen.com", password: "ChangeMe!", confirmed_at: Time.zone.now, organization: Organization.first)
Profile.create(first_name: "Super", zip_code: "80206", user: admin_user)
admin_user.add_role(:admin, Organization.first)
puts "Admin User Created - Username: #{admin_user.email}, Password: ChangeMe!"

Organization.create(name: "Admin", subdomain: "www")
admin_user = User.create(email: "admin2@commercekitchen.com", password: "ChangeMe!", confirmed_at: Time.zone.now, organization: Organization.second)
Profile.create(first_name: "Super", zip_code: "80206", user: admin_user)
admin_user.add_role(:admin, Organization.second)
puts "Admin User Created - Username: #{admin_user.email}, Password: ChangeMe!"

Organization.create(name: "Nashville Public Library", subdomain: "npl")
admin_user = User.create(email: "admin+nash@commercekitchen.com", password: "ChangeMe!", confirmed_at: Time.zone.now, organization: Organization.third)
Profile.create(first_name: "Super", zip_code: "37115", user: admin_user)
admin_user.add_role(:admin, Organization.third)
puts "Admin User Created - Username: #{admin_user.email}, Password: ChangeMe!"

regular_user = User.create(email: "alex@commercekitchen.com", password: "asdfasdf", confirmed_at: Time.zone.now, organization: Organization.first)
Profile.create(first_name: "Alex", zip_code: "80209", user: regular_user)
puts "Regular User Created - Username: #{regular_user.email}, Password: asdfasdf"

dev_user = User.create(email: "dev@nowhere.com", password: "password", confirmed_at: Time.zone.now, organization: Organization.first)
Profile.create(first_name: "Developer", zip_code: "80209", user: dev_user)
dev_user.add_role(:admin, Organization.first)
puts "Regular User Created - Username: #{dev_user.email}, Password: password"

Topic.create(title: "Computers")
Topic.create(title: "Internet")
puts "#{Topic.count} topics created."

Language.create(name: "English")
Language.create(name: "Spanish")
puts "#{Language.count} languages created."
