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

# => temporary topics for development
Topic.create(title: "Road Warriors")
Topic.create(title: "ThunderDome")
Topic.create(title: "War Boys")
Topic.create(title: "Gas Town")

# => fake languages
Language.create(name: "Klingon")
Language.create(name: "Orc")
Language.create(name: "Zanzibarzian")

# => Temporary courses for development
6.times do 
  Course.create!(
  :title => Faker::Company.name,
  :seo_page_title => Faker::Company.bs,
  :meta_desc => Faker::Company.bs,
  :summary => Faker::Lorem.sentence(5),
  :description => Faker::Lorem.paragraph(3),
  :contributor => Faker.name,
  :pub_status => "p" 
  )
end


# => give each course a language and a topic
# Need to complete association to make this work

# Course.all.each do |c|
#   c.topics << Topic.all.sample
#   c.languages << Language.all.sample
# end