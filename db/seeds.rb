# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

admin_user = User.create(email: "admin@commercekitchen.com", password: "ChangeMe!", confirmed_at: Time.zone.now)
admin_profile = Profile.create(first_name: "Super", zip_code: "80206", user_id: admin_user.id)
admin_user.update(profile_id: admin_profile.id)
admin_user.add_role(:admin)
puts "Admin User Created - Username: #{admin_user.email}, Password: ChangeMe!"

regular_user = User.create(email: "alex@commercekitchen.com", password: "asdfasdf", confirmed_at: Time.zone.now)
admin_profile = Profile.create(first_name: "Alex", zip_code: "80209", user_id: regular_user.id)
regular_user.update(profile_id: admin_profile.id)
puts "Regular User Created - Username: #{regular_user.email}, Password: asdfasdf"

Topic.create(title: "Computers")
Topic.create(title: "Internet")
puts "#{Topic.count} topics created."

Language.create(name: "English")
Language.create(name: "Spanish")
puts "#{Language.count} languages created."

# => Temporary courses for development
6.times do |i|
  description = <<-DESCRIPTION
    Description for Sample Course #{i + 1}. At vero eos et accusamus et iusto odio \
    dignissimos ducimus qui blanditiis praesentium voluptatum deleniti \
    atque corrupti quos dolores et quas molestias excepturi \
    sint occaecati cupiditate non provident, similique sunt \
    in culpa qui officia deserunt mollitia animi, \
    id est laborum et dolorum fuga. Et harum quidem rerum \
    facilis est et expedita distinctio. Nam libero tempore, \
    cum soluta nobis est eligendi optio cumque nihil impedit \
    quo minus id quod maxime placeat facere possimus, omnis \
    voluptas assumenda est, omnis dolor repellendus. Temporibus \
    autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet \
    ut et voluptates repudiandae sint et molestiae non recusandae. \
    Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis \
    voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat..
  DESCRIPTION
  Course.create!(
    title: "Sample Course #{i + 1}",
    seo_page_title: "Sample Course #{i + 1}",
    meta_desc: "Meta Description for Sample Course #{i + 1}",
    summary: "Summary for Sample Course #{i + 1}",
    description: description,
    contributor: "John Doe",
    pub_status: "P",
    language_id: Language.first.id,
    level: "Beginner",
    pub_date: Time.zone.now
  )
end
puts "#{Course.count} courses created."

Course.all.each do |c|
  c.topics << Topic.first
  c.lessons << Lesson.create(title: "Lesson 1", summary: "Lesson A summary", duration: 90, lesson_order: 1)
  c.lessons << Lesson.create(title: "Lesson 2", summary: "Lesson B summary", duration: 120, lesson_order: 2)
  c.lessons << Lesson.create(title: "Lesson 3", summary: "Lesson C summary", duration: 80, lesson_order: 3)
  c.lessons << Lesson.create(title: "Lesson 4", summary: "Lesson D summary", duration: 40, lesson_order: 4)
  c.save
end
