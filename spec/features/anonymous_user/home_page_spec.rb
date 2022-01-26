# frozen_string_literal: true

require 'feature_helper'

feature 'User views home page' do
  let(:org) { FactoryBot.create(:default_organization) }
  let(:more_courses_message) { 'More courses are available if you' }

  context 'organization has no private courses' do
    let!(:course) do
      FactoryBot.create(:course, organization: org, access_level: :everyone)
    end

    scenario 'should not see more courses message' do
      visit root_path
      expect(page).not_to have_content(more_courses_message)
    end
  end

  context 'organization has private courses' do
    let!(:private_course) do
      FactoryBot.create(:course,
                        organization: org,
                        access_level: :authenticated_users)
    end

    scenario 'should see more courses link for published private course' do
      visit root_path
      expect(page).to have_content(more_courses_message)
    end

    scenario 'should see more courses link for coming soon private course' do
      private_course.update(pub_status: 'C')
      visit root_path
      expect(page).to have_content(more_courses_message)
    end

    scenario 'should not see the more courses link for draft private course' do
      private_course.update(pub_status: 'D')
      visit root_path
      expect(page).not_to have_content(more_courses_message)
    end

    scenario 'should not see the more courses link for archived private course' do
      private_course.update(pub_status: 'A')
      visit root_path
      expect(page).not_to have_content(more_courses_message)
    end
  end
end
