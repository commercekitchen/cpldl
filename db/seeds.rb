# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

admin_user = User.create(email: "admin@commercekitchen.com", password: "ChangeMe!", confirmed_at: Time.zone.now)
admin_profile = Profile.create(first_name: "Super", last_name: "User", zip_code: "80206", user_id: admin_user.id)
admin_user.update(profile_id: admin_profile.id)
admin_user.add_role(:admin)
puts "Admin User Created - Username: #{admin_user.email}, Password: password"

regular_user = User.create(email: "alex@commercekitchen.com", password: "asdfasdf", confirmed_at: Time.zone.now)
admin_profile = Profile.create(first_name: "Alex", last_name: "Brinkman", zip_code: "80209", user_id: regular_user.id)
regular_user.update(profile_id: admin_profile.id)
puts "Regular User Created - Username: #{regular_user.email}, Password: password"

Topic.create(title: "Computers")
Topic.create(title: "Internet")
puts "#{Topic.count} topics created."

Language.create(name: "English")
Language.create(name: "Spanish")
puts "#{Language.count} languages created."

# => Temporary courses for development
6.times do |i|
  description = <<-DESCRIPTION
    Description for Sample Course #{i+1}. At vero eos et accusamus et iusto odio
    dignissimos ducimus qui blanditiis praesentium voluptatum deleniti
    atque corrupti quos dolores et quas molestias excepturi
    sint occaecati cupiditate non provident, similique sunt
    in culpa qui officia deserunt mollitia animi,
    id est laborum et dolorum fuga. Et harum quidem rerum
    facilis est et expedita distinctio. Nam libero tempore,
    cum soluta nobis est eligendi optio cumque nihil impedit
    quo minus id quod maxime placeat facere possimus, omnis
    voluptas assumenda est, omnis dolor repellendus. Temporibus
    autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet
    ut et voluptates repudiandae sint et molestiae non recusandae.
    Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis
    voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat..
  DESCRIPTION
  Course.create!(
    title: "Sample Course #{i+1}",
    seo_page_title: "Sample Course #{i+1}",
    meta_desc: "Meta Description for Sample Course #{i+1}",
    summary: "Summary for Sample Course #{i+1}",
    description: description,
    contributor: "John Doe",
    pub_status: "P",
    language_id: Language.first.id,
    level: "Beginner"
  )
end
puts "#{Course.count} courses created."

Course.all.each do |c|
  c.topics << Topic.first
  c.lessons << Lesson.create(title: "Lesson 1", description: "Lesson A description", duration: 90, order: 1)
  c.lessons << Lesson.create(title: "Lesson 2", description: "Lesson B description", duration: 120, order: 2)
  c.lessons << Lesson.create(title: "Lesson 3", description: "Lesson C description", duration: 80, order: 3)
  c.lessons << Lesson.create(title: "Lesson 4", description: "Lesson D description", duration: 40, order: 4)
  c.save
end
