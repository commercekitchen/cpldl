# frozen_string_literal: true

require 'feature_helper'

feature 'Admin courses' do
  let(:pla) { FactoryBot.create(:default_organization) }
  let(:dpl) { FactoryBot.create(:organization, subdomain: 'dpl') }

  let!(:dpl_category) { FactoryBot.create(:category, organization: dpl) }
  let!(:dpl_disabled_category) { FactoryBot.create(:category, :disabled, organization: dpl) }

  let!(:pla_category) { create(:category, organization: pla) }
  let!(:pla_category_repeat_name) { create(:category, name: dpl_category.name, organization: pla) }
  let!(:pla_disabled_category) { create(:category, :disabled, organization: pla) }

  let!(:importable_course1)  { FactoryBot.create(:course_with_lessons, organization: pla, category: pla_category) }
  let!(:importable_course2)  { FactoryBot.create(:course_with_lessons, organization: pla, category: pla_category) }
  let!(:importable_course3)  { FactoryBot.create(:course_with_lessons, organization: pla, category: pla_category_repeat_name) }
  let!(:importable_course4)  { FactoryBot.create(:course_with_lessons, organization: pla) }

  let!(:dpl_course1) { FactoryBot.create(:course_with_lessons, organization: dpl, category: dpl_category) }
  let!(:dpl_course2) { FactoryBot.create(:course_with_lessons, organization: dpl, category: dpl_category) }
  let!(:dpl_course3) { FactoryBot.create(:course_with_lessons, organization: dpl) }

  let(:pla_admin) { FactoryBot.create(:user, :admin, organization: pla) }
  let(:dpl_admin) { FactoryBot.create(:user, :admin, organization: dpl) }

  context 'subdomain admin' do
    before do
      switch_to_subdomain(dpl.subdomain)
      login_as(dpl_admin)
    end

    scenario 'will see links to edit courses on courses page' do
      visit admin_root_path
      click_link dpl_course1.title
      expect(current_path).to eq edit_admin_course_path(dpl_course1)
    end

    scenario 'will see categories' do
      visit admin_root_path
      expect(page).to have_content(dpl_category.name, count: 1)
    end

    scenario 'will see label for disabled categories' do
      visit admin_root_path
      expect(page).to have_content("#{dpl_disabled_category.name} (disabled)")
    end

    scenario 'will see uncategorized section' do
      visit admin_root_path
      expect(page).to have_content('Uncategorized', count: 1)
    end

    scenario 'will see importable courses' do
      visit admin_import_courses_path
      expect(page).to have_content(importable_course1.title)
    end

    scenario 'will see importable course links' do
      visit admin_import_courses_path
      expected_href = admin_dashboard_add_imported_course_path(course_id: importable_course1.id)
      expect(page).to have_link('Import Course', href: expected_href)
    end

    scenario 'will see pla category headers for importable courses' do
      visit admin_import_courses_path
      expect(page).to have_content(pla_category.name, count: 1)
    end

    scenario 'will see label for disabled categories' do
      visit admin_import_courses_path
      expect(page).to have_content("#{pla_disabled_category.name} (disabled)")
    end

    scenario 'will see uncategorized header for importable courses' do
      visit admin_import_courses_path
      expect(page).to have_content('Uncategorized', count: 1)
    end

    scenario 'wont see repeat links to imported courses on course import page' do
      visit admin_import_courses_path
      expect(page).not_to have_content(dpl_course1.title)
    end

    scenario 'adding a categorized course for new category should create category' do
      visit admin_import_courses_path

      expect do
        click_link('Import Course', href: admin_dashboard_add_imported_course_path(course_id: importable_course1.id))
      end.to change(Category, :count).by(1)

      expect(page).to have_content('Edit This Course')
      expect(page).to have_select('course_category_id', selected: pla_category.name)
    end

    scenario 'adding a categorized course for an existing category name should not create category' do
      visit admin_import_courses_path

      expect do
        click_link('Import Course', href: admin_dashboard_add_imported_course_path(course_id: importable_course3.id))
      end.not_to change(Category, :count)

      expect(page).to have_content('Edit This Course')
      expect(page).to have_select('course_category_id', selected: dpl_category.name)
    end
  end

  context 'PLA admin' do
    before do
      switch_to_subdomain(pla.subdomain)
      login_as(pla_admin)
    end

    scenario 'will see edit links in categories' do
      visit admin_root_path
      expect(page).to have_content(pla_category.name, count: 1)
    end

    scenario 'will see label for disabled courses' do
      visit admin_root_path
      expect(page).to have_content("#{pla_disabled_category.name} (disabled)")
    end

    scenario 'will see uncategorized section' do
      visit admin_root_path
      expect(page).to have_content('Uncategorized', count: 1)
    end

    scenario 'can see links to edit courses' do
      visit admin_root_path
      click_link importable_course2.title
      expect(current_path).to eq edit_admin_course_path(importable_course2)
    end
  end
end
