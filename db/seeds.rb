# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# => super user account
# => CHANGE pwd for production!!!
super_user = User.create(email: "super@commercekitchen.com", password: "password", confirmed_at: Time.zone.now)
super_profile = Profile.create(first_name: "Super", last_name: "User", zip_code: "80206", user_id: super_user.id)
super_user.update(profile_id: super_profile.id)
super_user.add_role(:super)

puts "Super User Created - Username: super@commercekitchen.com, Password: password "

# => temporary topics for development
Topic.create(title: "Road Warriors")
Topic.create(title: "ThunderDome")
Topic.create(title: "War Boys")
Topic.create(title: "Gas Town")
puts "#{Topic.count} topics created."

# => fake languages
Language.create(name: "Klingon")
Language.create(name: "Orc")
Language.create(name: "Zanzibarzian")
puts "#{Language.count} languages created."

# => Temporary courses for development
6.times do
  Course.create!(
  title: Faker::Company.name,
  seo_page_title: Faker::Company.bs,
  meta_desc: Faker::Company.bs,
  summary: Faker::Lorem.sentence(5),
  description: Faker::Lorem.paragraph(3),
  contributor: Faker.name,
  pub_status: "P",
  language_id: Language.all.sample.id,
  level: ["Beginner", "Intermediate", "Advanced"].sample
  )
end
puts "#{Course.count} courses created."

Course.all.each do |c|
  c.topics << Topic.all.sample
  c.lessons << Lesson.create(title: "Lesson 1", description: "Lesson A description", duration: 90, order: 1)
  c.lessons << Lesson.create(title: "Lesson 2", description: "Lesson B description", duration: 120, order: 2)
  c.lessons << Lesson.create(title: "Lesson 3", description: "Lesson B description", duration: 80, order: 3)
  c.lessons << Lesson.create(title: "Lesson 4", description: "Lesson B description", duration: 40, order: 4)
  c.save
end
puts "courses updated with topics, languages, and lessons."


