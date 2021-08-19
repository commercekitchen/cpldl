class SetExistingPublicationStatuses < ActiveRecord::Migration[5.2]
  def up
    [['P', 'published'], ['D', 'draft'], ['A', 'archived']].each do |pub_status, publication_status|
      courses = Course.where(pub_status: pub_status)
      puts "Courses with pub_status #{pub_status}: #{courses.count}"

      courses.update_all(publication_status: publication_status)
      
      migrated_courses = Course.where(publication_status: publication_status)
      puts "Courses migrated to publication_status #{publication_status}: #{migrated_courses.count}"
    end

    puts "Coming Soon courses to migrate: #{Course.where(pub_status: 'C').count}"
    Course.where(pub_status: 'C').update_all(publication_status: 'draft', coming_soon: true)
    puts "Coming Soon courses migrated: #{Course.where(coming_soon: true).count}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
