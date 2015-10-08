# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# => super user account
super_user = User.create(email: "super@commercekitchen.com",
                      password: "superM@n",
                  confirmed_at: Time.now)

super_profile = Profile.create(first_name: "Super",
                                last_name: "User",
                                 zip_code: "80206",
                                  user_id: super_user.id)

super_user.update(profile_id: super_profile.id)
super_user.add_role(:super)