# frozen_string_literal: true

require 'feature_helper'

feature 'Admin previews a PLA course' do
  let(:pla) { FactoryBot.create(:default_organization) }
  let(:subsite_admin) { FactoryBot.create(:user, :admin) }
  let(:org) { subsite_admin.organization }

  let!(:pla_course) { FactoryBot.create(:course_with_lessons, organization: pla) }

  before do
    switch_to_subdomain(org.subdomain)
    login_as subsite_admin
    visit admin_dashboard_index_path
  end

  scenario 'admin clicks course preview link from course import view' do
    click_link 'Import DigitalLearn Courses'
    click_link 'Preview Course'
    expect(current_path).to eq(admin_course_preview_path(pla_course.id))
    expect(page).to have_content('You are previewing this course')

    expect(page).to have_link 'Return to Admin Panel'
    expect(page).to have_link 'Import Course'

    # Return to import courses view
    click_link 'Return to Admin Panel'
    expect(current_path).to eq(admin_import_courses_path)
    click_link 'Preview Course'

    # Course preview
    expect(page).to have_content(pla_course.title)

  end
end
