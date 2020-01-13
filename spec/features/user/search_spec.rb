# frozen_string_literal: true

require 'feature_helper'

feature 'User searches for courses' do
  let(:org) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: org) }
  let!(:course) { FactoryBot.create(:course, organization: org) }

  before do
    switch_to_subdomain(org.subdomain)
    login_as(user)
    visit root_path
  end

  scenario 'no courses found' do
    fill_in 'Search', with: 'foobar'
    click_on('submit-search')
    expect(page).to have_content('No courses match your search.')
    expect(page).to have_link('View all courses', href: courses_path)
  end

  scenario 'course found' do
    fill_in 'Search', with: course.title
    click_on('submit-search')
    expect(page).to have_content(course.summary)
  end
end
