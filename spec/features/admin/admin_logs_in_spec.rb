# frozen_string_literal: true

require 'feature_helper'

feature 'Admin user logs in' do
  context 'traditional log in organization' do
    before(:each) do
      @org = create(:organization)
      switch_to_subdomain(@org.subdomain)
      @user = create(:user, :first_time_user, organization: @org)
      @user.add_role(:admin, @org)
      switch_to_subdomain('chipublib')
    end

    context 'with valid profile' do
      scenario 'is sent to admin dashboard page' do
        visit new_user_session_path

        # Failed login attempt
        find('#login_email').set('foo@bar.com')
        find('#login_password').set('abc123')
        click_button 'Access Courses'
        expect(page).to have_content('Invalid Email or Password')

        # Successful login
        log_in_with @user.email, @user.password
        expect(current_path).to eq(admin_dashboard_index_path)
      end

      scenario "isn't prompted for quiz" do
        @user.update(quiz_modal_complete: false)
        log_in_with @user.email, @user.password
        expect(page).not_to have_css('#quiz-start-modal')
      end
    end

    context 'with invalid profile' do
      before(:each) do
        @user.profile.first_name = nil
        @user.profile.save(validate: false)
      end

      scenario 'is sent to profile page' do
        log_in_with @user.email, @user.password
        expect(current_path).to eq(profile_path)
      end

      scenario "can't navigate away from profile page with invalid profile" do
        log_in_with @user.email, @user.password
        visit new_admin_library_location_path
        expect(current_path).to eq(invalid_profile_path)
        expect(page).to have_content('You must have a valid profile before you can continue:')
        expect(page).to have_content("First name can't be blank")
      end
    end

    context 'with no profile' do
      before(:each) do
        @user.profile.destroy
      end

      scenario 'is prompted to update profile on first time sign in' do
        expect(@user.sign_in_count).to eq(0)
        log_in_with @user.email, @user.password
        expect(current_path).to eq(profile_path)
        expect(page).to have_content('This is the first time you have logged in, please update your profile.')
        click_link 'Sign Out'
      end

      scenario "can't navigate away from profile page with no profile" do
        log_in_with @user.email, @user.password
        visit new_admin_library_location_path
        expect(current_path).to eq(invalid_profile_path)
        expect(page).to have_content('You must have a valid profile before you can continue:')
        expect(page).to have_content("First name can't be blank")
      end
    end
  end

  context 'for library card login organization' do
    let(:location) { create(:library_location) }
    let(:org) do
      create(:organization, :library_card_login, subdomain: 'kclibrary', branches: true,
                       accepts_custom_branches: true, library_locations: [location])
    end
    let(:user) { build(:user, sign_in_count: 2) }

    before(:each) do
      user.add_role(:admin, org)
      user.update!(organization: org)
      switch_to_subdomain(org.subdomain)
    end

    context 'with no profile' do
      scenario 'can sign in with email and password' do
        user.update(profile: nil)
        log_in_with(user.email, user.password, true)
        expect(current_path).to eq(profile_path)
      end
    end

    context 'with valid profile' do
      scenario 'can sign in with email and password' do
        visit new_user_session_path(admin: true)

        # Failed login attempt
        find('#login_email').set('foo@bar.com')
        find('#login_password').set('abc123')
        click_button 'Access Courses'
        expect(page).to have_content('Invalid Email or Password')

        # Successful attempt
        log_in_with(user.email, user.password, true)
        expect(current_path).to eq(admin_dashboard_index_path)
      end
    end
  end

  context 'phone number organization' do
    let(:org) { create(:organization, subdomain: 'getconnected', phone_number_users_enabled: true) }
    let(:user) { create(:user) }

    before(:each) do
      user.add_role(:admin, org)
      user.update(organization: org)
      switch_to_subdomain(org.subdomain)
    end

    context 'with no profile' do
      scenario 'can sign in with email and password' do
        user.update(profile: nil)
        visit new_user_session_path
        click_link('Log In as Admin')
        expect(page).to have_current_path(new_user_session_path(admin: true))
        log_in_with(user.email, user.password, true)
        expect(current_path).to eq(profile_path)
      end
    end

    context 'with valid profile' do
      scenario 'can sign in with email and password' do
        visit new_user_session_path
        click_link('Log In as Admin')
        expect(page).to have_current_path(new_user_session_path(admin: true))
        
        # Failed login attempt
        find('#login_email').set('foo@bar.com')
        find('#login_password').set('abc123')
        click_button 'Access Courses'
        expect(page).to have_content('Invalid Email or Password')

        # Successful login
        find('#login_email').set(user.email)
        find('#login_password').set(user.password)
        click_button 'Access Courses'
        expect(current_path).to eq(admin_dashboard_index_path)
      end
    end
  end
end
