# frozen_string_literal: true

require 'feature_helper'

feature 'Admin user clicks through each page' do

  before(:each) do
    @spanish = FactoryBot.create(:spanish_lang)
    @english = FactoryBot.create(:language)
    @user = FactoryBot.create(:user)
    @user.add_role(:admin)
    @organization = FactoryBot.create(:organization)
    @category = FactoryBot.create(:category, organization: @user.organization)
    @course = FactoryBot.create(:course_with_lessons, category: @category, organization: @user.organization)
    @user.add_role(:admin, @organization)
    @user.organization.reload
    switch_to_subdomain('chipublib')
    log_in_with @user.email, @user.password
  end

  scenario 'can visit each link in the header' do
    visit admin_dashboard_index_path(subdomain: 'chipublib')
    expect(page).to have_content('Hi Admin!')

    visit admin_dashboard_index_path
    click_link 'Dashboard'
    expect(current_path).to eq(admin_dashboard_index_path)

    visit admin_dashboard_index_path
    click_link 'Sign Out'
    expect(current_path).to eq(root_path)
    expect(page).to have_content('Signed out successfully.')
  end

end
