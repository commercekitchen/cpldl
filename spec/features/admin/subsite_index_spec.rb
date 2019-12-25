# frozen_string_literal: true

require 'feature_helper'

feature 'Admin views list of subsites' do
  let(:main_site) { FactoryBot.create(:default_organization) }
  let(:user) { FactoryBot.create(:user, :admin, organization: main_site) }
  let(:subsite) { FactoryBot.create(:organization) }
  let!(:subsite_admin) { FactoryBot.create(:user, :admin, organization: subsite) }

  describe 'as a subsite admin' do
    before do
      switch_to_subdomain(subsite.subdomain)
      log_in_with subsite_admin.email, subsite_admin.password
    end

    scenario 'should not see the subsites link' do
      visit admin_dashboard_index_path
      expect(page).to_not have_link('Subsites')
    end
  end

  describe 'as a main site admin' do
    before do
      switch_to_subdomain('www')
      log_in_with user.email, user.password
    end

    scenario 'can view list of subsites' do
      visit admin_dashboard_index_path
      click_on 'Subsites'

      within(:css, '.callout') do
        expect(page).to have_content('Admin Dashboard')
      end

      within(:css, '.main-content') do
        expect(page).to have_css('h2', text: 'Subsites')
      end

      expect(page).to have_content(subsite.name)
      expect(page).to have_content(subsite.subdomain)
      expect(page).to have_content(subsite_admin.email)
    end

    scenario 'subsite preference icons' do
      subsite.update(branches: true)
      visit admin_organizations_path
      expect(page).to have_selector('i.icon-ok', count: 1)

      subsite.update(accepts_programs: true)
      visit admin_organizations_path
      expect(page).to have_selector('i.icon-ok', count: 2)

      subsite.update(accepts_partners: true)
      visit admin_organizations_path
      expect(page).to have_selector('i.icon-ok', count: 3)
    end
  end
end
