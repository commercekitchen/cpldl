# frozen_string_literal: true

require 'feature_helper'

feature 'Admin user updates course' do
  let(:story_line) do
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip'), 'application/zip')
  end

  let(:file_attachment) do
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf')
  end

  let(:pla) { FactoryBot.create(:default_organization) }
  let(:user) { FactoryBot.create(:user, :admin) }
  let(:org) { user.organization }
  let(:pla_course) { FactoryBot.create(:course, organization: pla) }
  let(:subsite_course) { FactoryBot.create(:course, organization: org, parent: pla_course) }
  let!(:course_attachment) do
    FactoryBot.create(:attachment, document: file_attachment, doc_type: 'post-course', course: subsite_course)
  end
  let!(:supplemental_attachment) do
    FactoryBot.create(:attachment, document: file_attachment, doc_type: 'supplemental', course: subsite_course)
  end

  let!(:topic) { FactoryBot.create(:topic) }
  let!(:category) { FactoryBot.create(:category, organization: org) }
  let!(:disabled_category) { FactoryBot.create(:category, :disabled, organization: org) }

  before(:each) do
    switch_to_subdomain(org.subdomain)
    log_in_with user.email, user.password
  end

  context 'imported PLA Course' do
    scenario 'sees restricted version of form' do
      visit edit_admin_course_path(subsite_course)
      ['Title',
       'Contributor',
       'Course Summary',
       'Course Description',
       'Content for Further Learning',
       topic.title,
       'Course Language',
       'Course Format',
       'Course Level',
       'SEO Page Title',
       'SEO Meta Description'].each do |label|
         expect(page).to have_field(label, disabled: true)
       end

      expect(page).to_not have_field('Other Topic')
      expect(page).to_not have_field('course_other_topic_text')
      expect(page).to_not have_link('Delete')
      expect(page).to_not have_css('.attachment-upload-fields')
      expect(page).to_not have_link('Add Attachment')

      expect(page).to have_content('Text copies of the course to allow users to download content and view offline or follow along with the online course.')
      expect(page).to have_content('Supplemental materials for further learning. These files are available to users after completing the course.')

      expect(page).to_not have_button('Publish Course')
      expect(page).to_not have_button('Edit Lessons')

      expect(page).to have_button('Publish')
      expect(page).to have_content('If you wish to edit details of this course and use the PLA-created Storyline files, please contact a PLA Administrator.')
      expect(page).to have_link('contact a PLA Administrator')
    end

    scenario 'changes access level for course' do
      visit edit_admin_course_path(subsite_course)
      within(:css, 'main') do
        select('Authenticated Users', from: 'course_access_level')
        click_button 'Publish'
      end
      expect(current_path).to eq(admin_dashboard_index_path)
      visit(edit_admin_course_path(subsite_course))
      expect(page).to have_select('course_access_level', selected: 'Authenticated Users')
    end

    scenario 'selects existing category for course' do
      visit edit_admin_course_path(subsite_course)
      within(:css, 'main') do
        select(category.name, from: 'course_category_id')
        click_button 'Publish'
      end
      expect(current_path).to eq(admin_dashboard_index_path)
      visit(edit_admin_course_path(subsite_course))
      expect(page).to have_select('course_category_id', selected: category.name)
    end

    scenario 'attempts to add a duplicate category to course' do
      visit edit_admin_course_path(subsite_course)
      within(:css, 'main') do
        select('Create new category', from: 'course_category_id')
        fill_in :course_category_attributes_name, with: category.name
        click_button 'Publish'
      end
      expect(current_path).to eq(admin_course_path(subsite_course))
      expect(page).to have_content('Category Name is already in use by your organization.')
      expect(page).to have_select('course_category_id', selected: 'Create new category')
      expect(page).to have_selector(:css, ".field_with_errors #course_category_attributes_name[value='#{category.name}']")
    end

    scenario 'adds a new category to course' do
      visit edit_admin_course_path(subsite_course)
      new_word = Faker::Lorem.word
      within(:css, 'main') do
        select('Create new category', from: 'course_category_id')
        fill_in :course_category_attributes_name, with: "#{category.name}_#{new_word}"
        click_button 'Publish'
      end
      expect(current_path).to eq(admin_dashboard_index_path)
      visit(edit_admin_course_path(subsite_course))
      expect(page).to have_select('course_category_id', selected: "#{category.name}_#{new_word}")
    end

    scenario 'can see which categories are disabled' do
      visit edit_admin_course_path(subsite_course)
      expect(page).to have_select('course_category_id', with_options: [category.name.to_s, "#{disabled_category.name} (disabled)"])
    end

    scenario 'can preview course' do
    end
  end

  context 'subsite created course' do
    let(:custom_subsite_course) { FactoryBot.create(:course, organization: org) }

    scenario 'attempts to upload attachments to course' do
      visit edit_admin_course_path(custom_subsite_course)
      attach_file 'Text Copies of Course', Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip')
      attach_file 'Additional Resources', Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip')
      click_button 'Publish Course'
      expect(page).to have_content('Attachments document is invalid. Only PDF, Word, PowerPoint, or Excel files are allowed.', count: 1)
    end

    scenario 'can edit course title' do
    end

    scenario 'can preview course' do
    end
  end
end
