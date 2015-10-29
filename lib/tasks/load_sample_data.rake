namespace :db do
  desc "Load sample data"
  task load_sample_data: :environment do
    puts "Loading sample data..."

    # => super user account
    # => CHANGE pwd for production!!!
    super_user = User.create(email: "super@cpl.com", password: "password", confirmed_at: Time.zone.now)
    super_profile = Profile.create(first_name: "Super", last_name: "User", zip_code: "80206", user_id: super_user.id)
    super_user.update(profile_id: super_profile.id)
    super_user.add_role(:admin)

    puts "Super User Created - Username: #{super_user.email}, Password: password"

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
        pub_status: %w(P D T).sample,
        language_id: Language.all.sample.id,
        level: %w(Beginner Intermediate Advanced).sample
      )
    end
    puts "#{Course.count} courses created."

    Course.all.each do |c|
      c.topics << Topic.all.sample
      c.lessons << Lesson.create(title: "Lesson 1", description: "Lesson A description", duration: 90, lesson_order: 1)
      c.lessons << Lesson.create(title: "Lesson 2", description: "Lesson B description", duration: 120, lesson_order: 2)
      c.lessons << Lesson.create(title: "Lesson 3", description: "Lesson B description", duration: 80, lesson_order: 3)
      c.lessons << Lesson.create(title: "Lesson 4", description: "Lesson B description", duration: 40, lesson_order: 4)
      c.save
    end
    puts "courses updated with topics, languages, and lessons."

    puts "Complete."
  end
end
