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

dev_user = User.create(email: "dev@nowhere.com", password: "password", confirmed_at: Time.zone.now)
admin_profile = Profile.create(first_name: "Developer", zip_code: "80209", user_id: dev_user.id)
dev_user.update(profile_id: admin_profile.id)
dev_user.add_role(:admin)
puts "Regular User Created - Username: #{dev_user.email}, Password: password"

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
    pub_status: %w(P D T).sample,
    language_id: Language.first.id,
    level: "Beginner",
    pub_date: Time.zone.now
  )
end

courses = Course.all
courses.each do |c|
  if c.pub_status == "P"
    c.pub_date = Time.zone.now
    c.save
  end
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

# => Temporary CMS pages for development
languages = Language.all.pluck(:id)
4.times do |i|
  content = <<-CONTENT
    Zombie ipsum reversus ab viral inferno, nam rick grimes malum cerebro. \
    De carne lumbering animata corpora quaeritis. Summus brains sit​​, morbo \
    vel maleficia? De apocalypsi gorger omero undead survivor dictum mauris. \
    Hi mindless mortuis soulless creaturas, imo evil stalking monstra adventus \
    resi dentevil vultus comedat cerebella viventium. Qui animated corpse, \
    cricket bat max brucks terribilem incessu zomby. The voodoo sacerdos \
    flesh eater, suscitat mortuos comedere carnem virus. Zonbi tattered for \
    solum oculi eorum defunctis go lum cerebro. Nescio brains an Undead zombies. \
    Sicut malus putrid voodoo horror. Nigh tofth eliv ingdead...
  CONTENT
  CmsPage.create!(
    title: "Sample Page #{i + 1}",
    page_type: %w(H C A O).sample,
    audience: %w(Unauth Auth Admin All).sample,
    body: content,
    language_id: languages.sample,
    pub_status: %w(P D T).sample,
    author: "Zombie Zach",
    seo_page_title: "Sample Page #{i + 1}",
    meta_desc: "Meta description for sample page #{i + 1}"
  )
end

CmsPage.all.each do |p|
  if p.pub_status == "P"
    p.pub_date = Time.zone.now
    p.save
  end
end
puts "#{CmsPage.count} pages created"
