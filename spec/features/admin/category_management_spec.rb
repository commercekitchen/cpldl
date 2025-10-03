# frozen_string_literal: true

require 'feature_helper'

feature 'Admin user visits category management page' do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, organization: organization) }
  let!(:category1) { create(:category, organization: organization) }
  let!(:category2) { create(:category, organization: organization) }
  let!(:category3) { create(:category, organization: organization) }

  before(:each) do
    switch_to_subdomain(organization.subdomain)
    log_in_with admin.email, admin.password
  end

  scenario 'sees all categories' do
    visit admin_categories_path
    expect(page).to have_content('Categories')
    expect(page).to have_content(category1.name)
    expect(page).to have_content(category2.name)
    expect(page).to have_content(category3.name)
  end

  scenario 'can add new category', js: true do
    new_word = Faker::Lorem.word
    visit admin_categories_path
    fill_in 'category_name', with: "#{category1.name}_#{new_word}"
    click_on 'Add Category'
    expect(page).to have_content "#{category1.name}_#{new_word}"
  end

  scenario 'sees error if category name exists', js: true do
    visit admin_categories_path
    fill_in 'category_name', with: category1.name
    click_on 'Add Category'
    expect(page).to have_content('Category Name is already in use by your organization.')
    expect(page).to have_selector(:css, '.field_with_errors #category_name')
  end

  scenario 'can disable category', js: true do
    visit admin_categories_path
    click_on "category_toggle_link_#{category1.id}"
    expect(page).to have_selector(:css, ".table_row_disabled #category_toggle_link_#{category1.id}")
    category1.reload
    expect(category1.enabled).to eq(false)
  end
end
