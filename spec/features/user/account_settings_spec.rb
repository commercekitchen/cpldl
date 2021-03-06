# frozen_string_literal: true

require 'feature_helper'

feature 'Registered user visits account pages' do

  context 'belongs to non-program subdomain' do

    before(:each) do
      switch_to_subdomain('chipublib')
      @organization = create(:organization)
      @user = create(:user, organization: @organization)
      login_as(@user)
    end

    scenario 'sees the correct sidebar options' do
      visit account_path
      expect(page).to have_link('Login Information')
      expect(page).to have_link('Profile')
      expect(page).to have_link('Completed Courses')
    end

    scenario 'can change login information' do
      original_encrypted_pw = @user.encrypted_password
      visit account_path
      fill_in 'Email', with: 'alex@commercekitchen.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      click_button 'Save'

      @user.reload
      expect(@user.encrypted_password).not_to eq original_encrypted_pw
    end

    scenario 'can update their profile information' do
      visit profile_path
      fill_in 'First Name', with: 'Alex'
      fill_in 'Zip Code', with: '12345'
      select('English', from: 'profile_language_id')
      click_button 'Save'

      @user.reload
      expect(@user.profile.first_name).to eq('Alex')
      expect(@user.profile.zip_code).to eq('12345')
      expect(@user.profile.language.name).to eq('English')
    end

    scenario 'can change language preference' do
      visit profile_path
      select('Spanish', from: 'profile_language_id')
      click_button 'Save'

      expect(page).to have_content 'El perfil se actualizó correctamente.'
      expect(page).to have_content 'Idioma de preferencia'

      select('English', from: 'profile_language_id')
      click_button 'Guardar'

      expect(page).to have_content 'Profile was successfully updated.'
      expect(page).to have_content 'Preferred Language'
    end
  end

  context 'belongs to program subdomain' do

    before(:each) do
      @program_organization = create(:organization, :accepts_programs, subdomain: 'npl')
      @program_profile = build(:profile, :with_last_name)
      @program_user = create(:user, organization: @program_organization, profile: @program_profile)
      switch_to_subdomain(@program_organization.subdomain)
      login_as(@program_user)
    end

    scenario 'can update profile information' do
      # TODO: add npl specific fields
      visit profile_path
      fill_in 'First Name', with: 'Alex'
      fill_in 'Last Name', with: 'Monroe'
      fill_in 'Zip Code', with: '12345'
      select('English', from: 'profile_language_id')
      click_button 'Save'

      @program_user.reload
      expect(@program_user.profile.first_name).to eq('Alex')
      expect(@program_user.profile.last_name).to eq('Monroe')
      expect(@program_user.profile.zip_code).to eq('12345')
      expect(@program_user.profile.language.name).to eq('English')
    end

    scenario 'last name required' do
      visit profile_path
      fill_in 'First Name', with: 'Alex'
      fill_in 'Last Name', with: ''
      click_button 'Save'
      expect(page).to have_content "Last name can't be blank"
    end

  end

  context 'belongs to library card login organization' do
    let(:org) { FactoryBot.create(:organization, :library_card_login) }
    let(:user) { FactoryBot.create(:user, :library_card_login_user, organization: org) }

    before(:each) do
      switch_to_subdomain(org.subdomain)
      user.update(sign_in_count: 2) # To prevent first time sign in events
      library_card_log_in_with(user.library_card_number, user.library_card_pin)
    end

    scenario 'can view their account options' do
      visit root_path
      click_link 'Account'
      expect(page).to_not have_link('Login Information') # Library Card login users shouldn't see this
      expect(page).to have_link('Profile')
      expect(page).to have_link('Completed Courses')
    end

    scenario 'can update their profile information' do
      visit profile_path
      fill_in 'First Name', with: 'Alex'
      fill_in 'Zip Code', with: '12345'
      select('English', from: 'profile_language_id')
      click_button 'Save'

      user.reload
      expect(user.profile.first_name).to eq('Alex')
      expect(user.profile.zip_code).to eq('12345')
      expect(user.profile.language.name).to eq('English')
    end

    scenario 'can change language preference' do
      visit profile_path
      select('Spanish', from: 'profile_language_id')
      click_button 'Save'

      expect(page).to have_content 'El perfil se actualizó correctamente.'
      expect(page).to have_content 'Idioma de preferencia'

      select('English', from: 'profile_language_id')
      click_button 'Guardar'

      expect(page).to have_content 'Profile was successfully updated.'
      expect(page).to have_content 'Preferred Language'
    end
  end

  context 'belongs to custom branch organization', js: true do
    let(:org) { FactoryBot.create(:organization, branches: true, accepts_custom_branches: true) }
    let!(:library_location1) { FactoryBot.create(:library_location, organization: org) }
    let!(:library_location2) { FactoryBot.create(:library_location, organization: org) }
    let(:profile) { FactoryBot.build(:profile, library_location: library_location1) }
    let(:user) { FactoryBot.create(:user, organization: org, profile: profile) }

    before(:each) do
      switch_to_subdomain(org.subdomain)
      log_in_with(user.email, user.password)

      visit profile_path
    end

    scenario 'can change library location' do
      expect(page).to have_select('chzn', selected: library_location1.name)

      select library_location2.name, from: :chzn
      click_on('Save')
      expect(page).to have_content('Profile was successfully updated.')

      visit profile_path
      expect(page).to have_select('chzn', selected: library_location2.name)
    end

    scenario 'can choose custom location' do
      expect(page).to have_css('#custom_branch_name', visible: false)

      select 'Community Partner', from: :chzn

      expect(page).to have_css('#custom_branch_name', visible: true)

      fill_in 'Community Partner Name', with: 'New Branch'

      expect do
        click_button 'Save'
      end.to change(LibraryLocation, :count).by(1)

      visit profile_path

      expect(page).to have_select('chzn', selected: 'New Branch')
    end
  end

end
