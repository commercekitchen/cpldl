require 'feature_helper'

feature 'User searches for courses' do
  let(:org) { FactoryBot.create(:organization) }
  let!(:course) { FactoryBot.create(:course, organization: org) }

  before do
    switch_to_subdomain(org.subdomain)
    visit root_path
  end

  scenario 'no courses found' do
    fill_in 'Search', with: 'foobar'
    click_on('submit-search')
    expect(page).not_to have_content(I18n.t("home.choose_a_course.#{org.subdomain}"))
    expect(page).not_to have_content(I18n.t("home.choose_course_subheader.#{org.subdomain}"))
    expect(page).to have_content('No courses match your search.')
    expect(page).to have_link('View all courses', href: courses_path)
  end

  scenario 'course found' do
    fill_in 'Search', with: course.title
    click_on('submit-search')
    expect(page).to have_content(course.summary)
  end
end
