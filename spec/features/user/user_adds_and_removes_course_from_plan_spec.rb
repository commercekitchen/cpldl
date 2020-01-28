# frozen_string_literal: true

require 'feature_helper'

feature 'User is able to add and remove a course from their plan' do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:course) { FactoryBot.create(:course, title: 'Title 1', organization: organization) }

  before(:each) do
    switch_to_subdomain(organization.subdomain)
    login_as(user)
  end

  context 'as a logged in user' do
    scenario 'can click to add a course to their plan' do
      visit course_path(course)
      click_link 'Add to your plan'
      expect(current_path).to eq(course_path(course))
      expect(page).to have_content('Successfully added this course to your plan.')

      click_link 'Remove from your plan'
      expect(current_path).to eq(course_path(course))
      expect(page).to have_content('Successfully removed this course to your plan.')
    end
  end
end
