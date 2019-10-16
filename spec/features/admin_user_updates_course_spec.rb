# frozen_string_literal: true

require 'feature_helper'

feature 'Admin user updates course' do
  before(:each) do
    @topic = FactoryBot.create(:topic)
    @spanish = FactoryBot.create(:spanish_lang)
    @story_line = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/BasicSearch1.zip'), 'application/zip')

    @organization = FactoryBot.create(:organization)
    @user = FactoryBot.create(:user, organization: @organization)
    @user.add_role(:admin)
    @user.add_role(:admin, @organization)

    @course = FactoryBot.create(:course, organization: @organization)
    @category = FactoryBot.create(:category, organization: @organization)
    @disabled_category = FactoryBot.create(:category, :disabled, organization: @organization)
    switch_to_subdomain('chipublib')
    log_in_with @user.email, @user.password
  end

  scenario 'selects existing category for course' do
    visit edit_admin_course_path(@course)
    expect(page).to have_content('Course Information')
    within(:css, 'main') do
      select(@category.name, from: 'course_category_id')
      click_button 'Save Course'
    end
    expect(current_path).to eq(edit_admin_course_path(Course.last))
    expect(page).to have_select('course_category_id', selected: @category.name)
  end

  scenario 'attempts to add a duplicate category to course' do
    visit edit_admin_course_path(@course)
    expect(page).to have_content('Course Information')
    within(:css, 'main') do
      select('Create new category', from: 'course_category_id')
      fill_in :course_category_attributes_name, with: @category.name
      click_button 'Save Course'
    end
    expect(current_path).to eq(admin_course_path(Course.last))
    expect(page).to have_content('Category Name is already in use by your organization.')
    expect(page).to have_select('course_category_id', selected: 'Create new category')
    expect(page).to have_selector(:css, ".field_with_errors #course_category_attributes_name[value='#{@category.name}']")
  end

  scenario 'adds a new category to course' do
    visit edit_admin_course_path(@course)
    new_word = Faker::Lorem.word
    expect(page).to have_content('Course Information')
    within(:css, 'main') do
      select('Create new category', from: 'course_category_id')
      fill_in :course_category_attributes_name, with: "#{@category.name}_#{new_word}"
      click_button 'Save Course'
    end
    expect(current_path).to eq(edit_admin_course_path(Course.last))
    expect(page).to have_select('course_category_id', selected: "#{@category.name}_#{new_word}")
  end

  scenario 'can see which categories are disabled' do
    visit edit_admin_course_path(@course)
    expect(page).to have_select('course_category_id', with_options: [@category.name.to_s, "#{@disabled_category.name} (disabled)"])
  end
end
