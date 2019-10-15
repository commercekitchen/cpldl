# frozen_string_literal: true

require 'feature_helper'

feature 'User logs in' do

  context 'normal email and password' do
    before(:each) do
      @org = create(:organization)
      @spanish = create(:spanish_lang)
      @english = create(:language)
      switch_to_subdomain('chipublib')
    end

    scenario 'with valid email and password' do
      user = create(:user, organization: @org)
      user.add_role(:user, @org)
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
      user = create(:user, organization: @org)
      user.add_role(:user, @org)

      visit root_path

      click_link 'Español'

      spanish_log_in_with '', 'password'
      expect(page).to have_content('Email o Contraseña no válidos.')
    end

    scenario 'first time login non-program org' do
      user = create(:user, :first_time_user, organization: @org)
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

    scenario 'first time login with program org, with course recommendations' do
      @npl = create(:organization, :accepts_programs, subdomain: 'npl')
      @npl_profile = create(:profile, :with_last_name)
      @npl_user = create(:user, :first_time_user, organization: @npl, profile: @npl_profile)
      switch_to_subdomain('npl')
      log_in_with(@npl_user.email, @npl_user.password)

      expect(current_path).to eq(profile_path)

      fill_in 'Last Name', with: Faker::Name.last_name

      click_on 'Save'

      expect(current_path).to eq(new_quiz_response_path)
    end

    scenario 'first time login with program org, no course recommendations' do
      @npl = create(:organization, :accepts_programs, subdomain: 'npl')
      @npl_profile = build(:profile, :with_last_name)
      @npl_user = create(:user, :first_time_user, organization: @npl, profile: @npl_profile)
      switch_to_subdomain('npl')
      log_in_with(@npl_user.email, @npl_user.password)

      expect(current_path).to eq(profile_path)

      fill_in 'Last Name', with: Faker::Name.last_name
      choose 'profile_opt_out_of_recommendations_true'
      click_on 'Save'

      expect(current_path).to eq(root_path)
    end

    scenario 'with an invalid profile for a program org' do
      @npl = create(:organization, :accepts_programs, subdomain: 'npl')
      @npl_profile = create(:profile, :with_last_name)
      @npl_user = create(:user, organization: @npl, profile: @npl_profile)
      @npl_profile.update_attribute(:last_name, nil)
      switch_to_subdomain('npl')
      log_in_with(@npl_user.email, @npl_user.password)

      expect(current_path).to eq(profile_path)
    end

    scenario 'with a valid profile for a program org' do
      @npl = create(:organization, :accepts_programs, subdomain: 'npl')
      @npl_profile = create(:profile, :with_last_name)
      @npl_user = create(:user, organization: @npl, profile: @npl_profile)
      switch_to_subdomain('npl')
      log_in_with(@npl_user.email, @npl_user.password)

      expect(current_path).to eq(root_path)
    end

    scenario 'for incorrect organization' do
      other_org = create(:organization, subdomain: 'foobar')
      switch_to_subdomain(other_org.subdomain)

      user = create(:user, organization: @org)
      user.add_role(:user, @org)
      log_in_with(user.email, user.password)
      expect(current_path).to eq(login_path)
      expect(page).to have_content("Oops! You’re a member of #{@org.name}")
    end
  end

  context 'library card number and pin' do
    context 'new registration' do
      let(:organization) { create(:organization, :library_card_login) }
      let(:card_number) { Array.new(13) { rand(10) }.join }
      let(:card_pin) { Array.new(4) { rand(10) }.join }
      let(:first_name) { Faker::Name.first_name }
      let(:zip_code) { Array.new(5) { rand(10) }.join }

      before(:each) do
        @spanish = create(:spanish_lang)
        @english = create(:language)
        switch_to_subdomain(organization.subdomain)
      end

      scenario 'registers with card number and pin then signs in' do
        library_card_sign_up_with(card_number, card_pin, first_name, zip_code)

        click_link 'Sign Out'

        user = User.last # rubocop:disable Lint/UselessAssignment

        library_card_log_in_with(card_number, card_pin)
        expect(current_path).to eq(root_path)
        expect(page).to_not have_content('Signed in successfully.')
        expect(page).to have_content('Use a computer to do almost anything!')
        expect(page).to have_content(
          'Choose a course below to start learning, or visit My Courses to view your customized learning plan.'
        )
      end
    end

    context 'user already exists' do
      let(:org) { create(:organization, :library_card_login) }
      let(:user) { create(:user, :library_card_login_user, organization: org) }

      before(:each) do
        @spanish = create(:spanish_lang)
        @english = create(:language)
        switch_to_subdomain(org.subdomain)
      end

      scenario 'with invalid library card number' do
        library_card_log_in_with('12345', user.library_card_pin)
        expect(current_path).to eq(new_user_session_path)
        expect(page).to have_content('Invalid Library Card Number or Library Card PIN')
      end

      scenario 'with invalid pin' do
        library_card_log_in_with(user.library_card_number, '123')
        expect(current_path).to eq(new_user_session_path)
        expect(page).to have_content('Invalid Library Card Number or Library Card PIN')
      end
    end

    context 'spanish language user' do
      let(:org) { create(:organization, :library_card_login) }
      let(:user) { create(:user, :library_card_login_user, organization: org) }

      before(:each) do
        @spanish = create(:spanish_lang)
        @english = create(:language)
        switch_to_subdomain(org.subdomain)
        visit root_path
        click_link('Español')
      end

      scenario 'with invalid library card number' do
        spanish_library_card_log_in_with('12345', user.library_card_pin)
        expect(current_path).to eq(new_user_session_path)
        expect(page).to have_content('Número de tarjeta de biblioteca o PIN de tarjeta de biblioteca no válidos')
      end

      scenario 'with invalid pin' do
        spanish_library_card_log_in_with(user.library_card_number, '123')
        expect(current_path).to eq(new_user_session_path)
        expect(page).to have_content('Número de tarjeta de biblioteca o PIN de tarjeta de biblioteca no válidos')
      end
    end
  end

end
