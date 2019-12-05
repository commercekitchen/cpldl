# frozen_string_literal: true

require 'feature_helper'

feature 'User registration and login with library card number' do
  let(:organization) { FactoryBot.create(:organization, :library_card_login) }

  context 'new registration' do
    let(:card_number) { Array.new(13) { rand(10) }.join }
    let(:card_pin) { Array.new(4) { rand(10) }.join }
    let(:first_name) { Faker::Name.first_name }
    let(:zip_code) { Array.new(5) { rand(10) }.join }

    before(:each) do
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

    scenario 'attempts to register with invalid card number' do
      library_card_sign_up_with('123', card_pin, first_name, zip_code)
      expect(current_path).to eq(user_registration_path)
      expect(page).to have_content('Library Card Number is invalid')
    end

    scenario 'attempts to register and log in with number already in use at org' do
      FactoryBot.create(:user, :library_card_login_user, library_card_number: card_number, organization: organization)
      library_card_sign_up_with(card_number, card_pin, first_name, zip_code)

      expect(page).to have_content('Library Card Number has already been taken')
    end

    scenario 'attempts to register and log in with number in use at a different org' do
      FactoryBot.create(:user, library_card_number: card_number)
      library_card_sign_up_with(card_number, card_pin, first_name, zip_code)

      click_link 'Sign Out'

      library_card_log_in_with(card_number, card_pin)
      expect(current_path).to eq(root_path)
      expect(page).to have_content("Hi #{first_name}!")
    end
  end

  context 'existing user' do
    let(:org) { create(:organization, :library_card_login) }
    let(:user) { create(:user, :library_card_login_user, organization: org) }

    before(:each) do
      switch_to_subdomain(org.subdomain)
    end

    scenario 'attempts to log in with invalid library card number' do
      library_card_log_in_with('12345', user.library_card_pin)
      expect(current_path).to eq(new_user_session_path)
      expect(page).to have_content('Invalid Library Card Number or Library Card PIN')
    end

    scenario 'attempts to log in with invalid pin' do
      library_card_log_in_with(user.library_card_number, '123')
      expect(current_path).to eq(new_user_session_path)
      expect(page).to have_content('Invalid Library Card Number or Library Card PIN')
    end

    scenario 'attempts to log in with extra spaces' do
      library_card_log_in_with(" #{user.library_card_number}  ", user.library_card_pin)
      expect(current_path).to eq(root_path)
      expect(page).to_not have_content('Signed in successfully.')
    end
  end

  context 'spanish language user' do
    let(:org) { create(:organization, :library_card_login) }
    let(:user) { create(:user, :library_card_login_user, organization: org) }

    before(:each) do
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
