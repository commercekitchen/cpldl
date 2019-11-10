# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
Organization.create(name: 'Chicago Public Library', subdomain: 'chipublib')
Organization.create(name: 'Admin', subdomain: 'www')
Organization.create(name: 'Nashville Public Library', subdomain: 'npl')
Organization.create(name: 'Kansas City Public Library', subdomain: 'kclibrary')

class CreateSeedUser
  def self.generate(email, first_name, last_name, subdomain, admin = false)
    org = Organization.find_by!(subdomain: subdomain)
    password = 'ChangeMe!'
    if org.library_card_login?
      library_card_number = Array.new(7) { rand(1...9) }.join('')
      library_card_pin = '1234'
      password = Digest::MD5.hexdigest(library_card_pin).first(10)
    end
    user = User.create(email: email, password: password,
      organization: org, library_card_number: library_card_number, library_card_pin: library_card_pin)
    Profile.create(first_name: first_name, last_name: last_name, zip_code: '80206', user: user)
    user.add_role(:admin, org) if admin
    puts "User Created: #{user.email}, Password: ChangeMe!, #{admin ? 'Admin' : 'User'}"
  end
end

CreateSeedUser.generate('susie+npladmin@ckdtech.co', 'Susie', 'Lewis', 'npl', true)
CreateSeedUser.generate('susie+chipublibadmin@ckdtech.co', 'Susie', 'Lewis', 'chipublib', true)
CreateSeedUser.generate('ming+kclibraryadmin@ckdtech.co', 'Ming', '', 'kclibrary', true)
CreateSeedUser.generate('susie+wwwadmin@ckdtech.co', 'Susie', 'Lewis', 'www', true)

# Topics
Topic.create(title: 'Computers')
Topic.create(title: 'Internet')
puts "#{Topic.count} topics created."

# Languages
Language.create(name: 'English')
Language.create(name: 'Spanish')
puts "#{Language.count} languages created."
