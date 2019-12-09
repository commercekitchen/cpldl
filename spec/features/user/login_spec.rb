# frozen_string_literal: true

require 'feature_helper'

feature 'User logs in' do
  let(:org) { create(:organization) }

  context 'non-program subdomain' do
    before(:each) do
      switch_to_subdomain(org.subdomain)
    end

    scenario 'with valid email and password' do
      user = create(:user, organization: org)
      log_in_with(user.email, user.password)
      expect(current_path).to eq(root_path)
      expect(page).to_not have_content('Signed in successfully.')
      expect(page).to have_content('Use a computer to do almost anything!')
      expect(page).to have_content(
        'Choose a course below to start learning, or visit My Courses to view your customized learning plan.'
      )
    end

    scenario 'with invalid or blank email' do
      log_in_with '', 'password'

      expect(page).to have_content('Invalid Email or Password.')

      log_in_with 'not@real.com', 'password'
      expect(page).to have_content('Invalid Email or Password.')
    end

    scenario 'with blank password' do
      log_in_with 'valid@example.com', ''
      expect(page).to have_content('Invalid Email or Password.')

      log_in_with 'valid@example.com', 'no correct pwd'
      expect(page).to have_content('Invalid Email or Password.')
    end

    scenario 'spanish language user with invalid email' do
      create(:user, organization: org)

      visit root_path

      click_link 'Español'

      spanish_log_in_with '', 'password'
      expect(page).to have_content('Email o Contraseña no válidos.')
    end

    scenario 'first time login non-program org' do
      user = create(:user, :first_time_user, organization: org)
      past_time = 10.minutes.ago
      user.profile.update({ created_at: past_time, updated_at: past_time })
      log_in_with(user.email, user.password)
      expect(current_path).to eq(profile_path)

      click_on 'Save'
      user.profile.reload

      expect(current_path).to eq(new_quiz_response_path)
      visit profile_path
      click_on 'Save'

      expect(current_path).to eq(profile_path)
    end
  end

  context 'program subdomains' do
    let(:program_org) { create(:organization, :accepts_programs) }
    let(:profile) { create(:profile, :with_last_name) }

    scenario 'first time login with program org, with course recommendations' do
      @user = create(:user, :first_time_user, organization: program_org, profile: profile)
      switch_to_subdomain(program_org.subdomain)
      log_in_with(@user.email, @user.password)

      expect(current_path).to eq(profile_path)

      fill_in 'Last Name', with: Faker::Name.last_name

      click_on 'Save'

      expect(current_path).to eq(new_quiz_response_path)
    end

    scenario 'first time login with program org, no course recommendations' do
      @user = create(:user, :first_time_user, organization: program_org, profile: profile)
      switch_to_subdomain(program_org.subdomain)
      log_in_with(@user.email, @user.password)

      expect(current_path).to eq(profile_path)

      fill_in 'Last Name', with: Faker::Name.last_name
      choose 'profile_opt_out_of_recommendations_true'
      click_on 'Save'

      expect(current_path).to eq(root_path)
    end

    scenario 'with an invalid profile for a program org' do
      @user = create(:user, organization: program_org, profile: profile)
      profile.last_name = nil
      profile.save(validate: false)
      switch_to_subdomain(program_org.subdomain)
      log_in_with(@user.email, @user.password)

      expect(current_path).to eq(profile_path)
    end

    scenario 'with a valid profile for a program org' do
      @user = create(:user, organization: program_org, profile: profile)
      switch_to_subdomain(program_org.subdomain)
      log_in_with(@user.email, @user.password)

      expect(current_path).to eq(root_path)
    end
  end

  scenario 'for incorrect organization' do
    other_org = create(:organization, subdomain: 'foobar')
    switch_to_subdomain(other_org.subdomain)
    user = create(:user, organization: org)
    log_in_with(user.email, user.password)
    expect(current_path).to eq(user_session_path)
    expect(page).to have_content('Invalid Email or Password')
  end
end
