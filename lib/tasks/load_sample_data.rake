# frozen_string_literal: true

namespace :db do
  desc 'Load sample data'
  task load_sample_data: :environment do
    puts 'Loading sample data...'

    # => super user account
    # => CHANGE pwd for production!!!
    super_user = User.create(email: 'super@cpl.com', password: 'password', confirmed_at: Time.zone.now)
    super_profile = Profile.create(first_name: 'Super', zip_code: '80206', user_id: super_user.id)
    super_user.update(profile_id: super_profile.id)
    super_user.add_role(:admin)

    puts "Super User Created - Username: #{super_user.email}, Password: password"

    # => temporary topics for development
    Topic.create(title: 'Road Warriors')
    Topic.create(title: 'ThunderDome')
    Topic.create(title: 'War Boys')
    Topic.create(title: 'Gas Town')
    puts "#{Topic.count} topics created."

    # => fake languages
    Language.create(name: 'Klingon')
    Language.create(name: 'Orc')
    Language.create(name: 'Zanzibarzian')
    puts "#{Language.count} languages created."

    # => Temporary courses for development
    6.times do
      Course.create!(
        title: Faker::Company.name,
        seo_page_title: Faker::Company.bs,
        meta_desc: Faker::Company.bs,
        summary: Faker::Lorem.sentence(word_count: 5),
        description: Faker::Lorem.paragraph(3),
        contributor: Faker.name,
        pub_status: %w[P D T].sample,
        language_id: Language.all.sample.id,
        level: %w[Beginner Intermediate Advanced].sample
      )
    end
    puts "#{Course.count} courses created."

    Course.all.each do |c|
      c.topics << Topic.all.sample
      c.lessons << Lesson.create(title: 'Lesson 1', description: 'Lesson A description', duration: 90, lesson_order: 1)
      c.lessons << Lesson.create(title: 'Lesson 2', description: 'Lesson B description', duration: 120, lesson_order: 2)
      c.lessons << Lesson.create(title: 'Lesson 3', description: 'Lesson B description', duration: 80, lesson_order: 3)
      c.lessons << Lesson.create(title: 'Lesson 4', description: 'Lesson B description', duration: 40, lesson_order: 4)
      c.save
    end
    puts 'courses updated with topics, languages, and lessons.'

    puts 'Complete.'
  end
end

# TODO: this was from seeds.rb, where it didn't belong.  I'm not sure if this is better than what is in this file, need to verify.
# => Temporary courses for development
# 6.times do |i|
#   description = <<-DESCRIPTION
#     Description for Sample Course #{i + 1}. At vero eos et accusamus et iusto odio \
#     dignissimos ducimus qui blanditiis praesentium voluptatum deleniti \
#     atque corrupti quos dolores et quas molestias excepturi \
#     sint occaecati cupiditate non provident, similique sunt \
#     in culpa qui officia deserunt mollitia animi, \
#     id est laborum et dolorum fuga. Et harum quidem rerum \
#     facilis est et expedita distinctio. Nam libero tempore, \
#     cum soluta nobis est eligendi optio cumque nihil impedit \
#     quo minus id quod maxime placeat facere possimus, omnis \
#     voluptas assumenda est, omnis dolor repellendus. Temporibus \
#     autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet \
#     ut et voluptates repudiandae sint et molestiae non recusandae. \
#     Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis \
#     voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat..
#   DESCRIPTION
#   Course.create!(
#     title: "Sample Course #{i + 1}",
#     seo_page_title: "Sample Course #{i + 1}",
#     meta_desc: "Meta Description for Sample Course #{i + 1}",
#     summary: "Summary for Sample Course #{i + 1}",
#     description: description,
#     contributor: "John Doe",
#     pub_status: %w(P D A).sample,
#     language_id: Language.first.id,
#     level: "Beginner",
#     pub_date: Time.zone.now,
#     format: %w(M D).sample
#   )
# end
#
# courses = Course.all
# courses.each do |c|
#   if c.pub_status == "P"
#     c.pub_date = Time.zone.now
#     c.save
#   end
# end
#
# puts "#{Course.count} courses created."
#
# Course.all.each do |c|
#   c.topics << Topic.first
#   c.lessons << Lesson.create(title: "Lesson 1", summary: "Lesson A summary", duration: 90, lesson_order: 1, pub_status: "P")
#   c.lessons << Lesson.create(title: "Lesson 2", summary: "Lesson B summary", duration: 120, lesson_order: 2, pub_status: "P")
#   c.lessons << Lesson.create(title: "Lesson 3", summary: "Lesson C summary", duration: 80, lesson_order: 3, pub_status: "P")
#   c.lessons << Lesson.create(title: "Lesson 4", summary: "Lesson D summary", duration: 40, lesson_order: 4, pub_status: "P")
#   c.save
# end
#
# Course.all.each do |c|
#   c.organization = [Organization.first, Organization.second].sample
#   c.save
# end
#
# # => Temporary CMS pages for development
# languages = Language.all.pluck(:id)
# 4.times do |i|
#   content = <<-CONTENT
#     Zombie ipsum reversus ab viral inferno, nam rick grimes malum cerebro. \
#     De carne lumbering animata corpora quaeritis. Summus morbo \
#     vel maleficia? De apocalypsi gorger omero undead survivor dictum mauris. \
#     Hi mindless mortuis soulless creaturas, imo evil stalking monstra adventus \
#     resi dentevil vultus comedat cerebella viventium. Qui animated corpse, \
#     cricket bat max brucks terribilem incessu zomby. The voodoo sacerdos \
#     flesh eater, suscitat mortuos comedere carnem virus. Zonbi tattered for \
#     solum oculi eorum defunctis go lum cerebro. Nescio brains an Undead zombies. \
#     Sicut malus putrid voodoo horror. Nigh tofth eliv ingdead...
#   CONTENT
#   CmsPage.create!(
#     title: "Sample Page #{i + 1}",
#     audience: %w(Unauth Auth Admin All).sample,
#     body: content,
#     language_id: languages.sample,
#     pub_status: %w(P D A).sample,
#     author: "Zombie Zach",
#     seo_page_title: "Sample Page #{i + 1}",
#     meta_desc: "Meta description for sample page #{i + 1}"
#   )
# end
#
# CmsPage.all.each do |p|
#   if p.pub_status == "P"
#     p.pub_date = Time.zone.now
#     p.save
#   end
# end
# puts "#{CmsPage.count} pages created"
