class CreateYorkCountySubsite < ActiveRecord::Migration[5.2]
  def up
    org = Organization.create!(name: 'York County Library', subdomain: 'yclibrary')

    [ 'susie+yclibraryadmin@ckdtech.co',
      'julie.ward@yclibrary.org',
      'donna.andrews@yclibrary.org',
      'Greg.DeAngel@yclibrary.org',
      'troy.beckham@yclibrary.org' ].each do |admin|
        AdminInvitationService.invite(email: admin, organization: org)
    end

    # Import all available courses
    Course.where(pub_status: 'P', subsite_course: true).each do |course|
      CourseImportService.new(organization: org, course_id: course.id).import!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
