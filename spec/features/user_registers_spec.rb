require "feature_helper"

feature "User signs up" do

  context "organization has no programs" do
    before(:each) do
      create(:organization)
      @spanish = create(:spanish_lang)
      @english = create(:language)
      switch_to_subdomain("chipublib")
    end

    scenario "with valid email, password, first name, zip code" do
      sign_up_with "valid@example.com", "password", "Alejandro", "12345"
      expect(page).to have_content("This is the first time you have logged in, please update your profile.")

      # TODO: I'm not sure this is the best place for this expectation, but I'm not
      # sure where else to put it.  I just want to be sure the profile is created too.
      user = User.last
      expect(user.profile.first_name).to eq("Alejandro")
      expect(user.profile.zip_code).to eq("12345")
    end

    scenario "with valid email, password, first name, but no zip code" do
      sign_up_with "valid@example.com", "password", "Alejandro", ""
      expect(page).to have_content("This is the first time you have logged in, please update your profile.")

      user = User.last
      expect(user.profile.first_name).to eq("Alejandro")
      expect(user.profile.zip_code).to eq("")
    end

    scenario "with out first name" do
      sign_up_with "valid@example.com", "password", "", ""
      expect(page).to have_content("Profile first name can't be blank")
    end

    scenario "with invalid email" do
      sign_up_with "invalid_email", "password", "John", "55555"
      expect(page).to have_content("Email is invalid")
    end

    scenario "with blank password" do
      sign_up_with "valid@example.com", "", "John", "55555"
      expect(page).to have_content("Password can't be blank")
    end

    scenario "with non-matching passwords" do
      visit login_path
      find("#signup_email").set("valid@example.com")
      find("#signup_password").set("password")
      fill_in "user_password_confirmation", with: "PASSWORD"
      click_button "Sign Up"
      expect(page).to have_content("Password confirmation doesn't match Password")
    end
  end

  context "for a library_card_login organization" do
    let(:lib_card_number) { 13.times.map{rand(10)}.join }
    let(:lib_card_pin) { 4.times.map{rand(10)}.join }
    let(:first_name) { Faker::Name.first_name }
    let(:zip_code) { 5.times.map{rand(10)}.join }
    let(:invalid_card_number_short) { 10.times.map{rand(10)}.join }
    let(:invalid_card_number_long) { 15.times.map{rand(10)}.join }
    let(:invalid_pin_short) { 3.times.map{rand(10)}.join }
    let(:invalid_pin_long) { 5.times.map{rand(10)}.join }

    before(:each) do
      @org = create(:organization, :library_card_login)
      switch_to_subdomain(@org.subdomain)
    end

    scenario "with valid library card, library card pin, first name" do
      library_card_sign_up_with(lib_card_number, lib_card_pin, first_name, zip_code)
      expect(page).to have_content("This is the first time you have logged in, please update your profile.")

      user = User.last
      expect(user.profile.first_name).to eq(first_name)
      expect(user.profile.zip_code).to eq(zip_code)
    end

    scenario "with short library card number" do
      library_card_sign_up_with(invalid_card_number_short, lib_card_pin, first_name, zip_code)
      expect(current_path).to eq(user_registration_path)
      expect(page).to have_content("Library Card Number is invalid")
    end

    scenario "with long library card number" do
      library_card_sign_up_with(invalid_card_number_long, lib_card_pin, first_name, zip_code)
      expect(current_path).to eq(user_registration_path)
      expect(page).to have_content("Library Card Number is invalid")
    end

    scenario "with short pin" do
      library_card_sign_up_with(lib_card_number, invalid_pin_short, first_name, zip_code)
      expect(current_path).to eq(user_registration_path)
      expect(page).to have_content("Library Card PIN is invalid")
    end

    scenario "with long pin" do
      library_card_sign_up_with(lib_card_number, invalid_pin_long, first_name, zip_code)
      expect(current_path).to eq(user_registration_path)
      expect(page).to have_content("Library Card PIN is invalid")
    end

    scenario "with blank Library Card PIN" do
      library_card_sign_up_with(lib_card_number, "", first_name, zip_code)
      expect(current_path).to eq(user_registration_path)
      expect(page).to have_content("Library Card PIN is invalid")
    end

    scenario "without zip code" do
      library_card_sign_up_with(lib_card_number, lib_card_pin, first_name, "")
      expect(page).to have_content("This is the first time you have logged in, please update your profile.")

      user = User.last
      expect(user.profile.first_name).to eq(first_name)
      expect(user.profile.zip_code).to eq("")
    end

    scenario "without first name" do
      library_card_sign_up_with(lib_card_number, lib_card_pin, "", zip_code)
      expect(page).to have_content("Profile first name can't be blank")
    end
  end

end
