# frozen_string_literal: true

class CreateClevelandOrganization < ActiveRecord::Migration[5.2]
  def up
    cleveland = Organization.create!(name: 'Cleveland Foundation', subdomain: 'cleveland', accepts_partners: true)

    AdminInvitationService.invite(email: 'cwilliams@clevefdn.org', organization: cleveland)

    ['Ashbury Senior Computer Community Center',
     'CHN Housing Partners',
     'Cleveland Public Library',
     'Cuyahoga County Public Library',
     'Cuyahoga Metropolitan Housing Authority',
     'DigitalC',
     'East Cleveland Public Library',
     'PCs for People',
     'Other'].each do |partner|
      cleveland.partners.create!(name: partner)
    end

    Course.where(pub_status: 'P', subsite_course: true).each do |course|
      CourseImportService.new(organization: cleveland, course_id: course.id).import!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
