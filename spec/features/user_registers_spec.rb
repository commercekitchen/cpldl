require "feature_helper"

feature "User signs up" do
  let(:email) { Faker::Internet.free_email }
  let(:password) { Faker::Internet.password }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:zip_code) { Faker::Address.zip }

  before(:each) do
    @spanish = create(:spanish_lang)
    @english = create(:language)
  end

  context "organization has no programs" do
    before(:each) do
      create(:organization, subdomain: 'chipublib')
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

      # Log out and back in
      log_out

      log_in_with("valid@example.com", "password")
      expect(current_path).to eq(root_path)
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
    let(:lib_card_number) { Array.new(7) { rand(10) }.join }
    let(:lib_card_pin) { Array.new(4) { rand(10) }.join }
    let(:invalid_card_number_short) { Array.new(6) { rand(10) }.join }
    let(:invalid_card_number_long) { Array.new(15) { rand(10) }.join }
    let(:invalid_pin_short) { Array.new(3) { rand(10) }.join }
    let(:invalid_pin_long) { Array.new(5) { rand(10) }.join }

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

    scenario "with no library card number" do
      library_card_sign_up_with("", lib_card_pin, first_name, zip_code)
      expect(current_path).to eq(user_registration_path)
      expect(page).to_not have_css("#signup_email", visible: true)
      expect(page).to have_css("#library_card_number", visible: true)
    end

    scenario "with short library card number" do
      library_card_sign_up_with(invalid_card_number_short, lib_card_pin, first_name, zip_code)
      expect(current_path).to eq(user_registration_path)
      expect(page).to have_content("Library Card Number is invalid")
    end

    scenario "with long library card number" do
      library_card_sign_up_with(invalid_card_number_long, lib_card_pin, first_name, zip_code)
      expect(current_path).to eq(profile_path)
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

  context "by selecting a branch" do
    let(:org) { create(:organization, branches: true, accepts_custom_branches: true) }
    let(:library_location) { create(:library_location, organization: org) }

    before do
      org.library_locations << library_location
    end

    scenario "registers" do
      switch_to_subdomain(org.subdomain)

      visit login_path
      find("#signup_email").set(email)
      find("#signup_password").set(password)
      find("#user_profile_attributes_first_name").set(first_name)
      find("#user_profile_attributes_zip_code").set(zip_code)
      fill_in "user_password_confirmation", with: password

      select library_location.name, from: :chzn

      click_button "Sign Up"

      expect(page).to have_content("This is the first time you have logged in, please update your profile.")

      user = User.last
      expect(user.library_location_name).to eq(library_location.name)
    end
  end

  context "with a custom branch name", js: true do
    let(:org) { create(:organization, branches: true, accepts_custom_branches: true) }
    let(:email) { Faker::Internet.free_email }
    let(:password) { Faker::Internet.password }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:zip_code) { Faker::Address.zip }

    before do
      org.library_locations << create(:library_location, organization: org)
    end

    scenario "registers" do
      switch_to_subdomain(org.subdomain)

      visit login_path
      find("#signup_email").set(email)
      find("#signup_password").set(password)
      find("#user_profile_attributes_first_name").set(first_name)
      find("#user_profile_attributes_zip_code").set(zip_code)
      fill_in "user_password_confirmation", with: password

      expect(page).to have_css("#custom_branch_name", visible: false)

      select "Community Partner", from: :chzn

      expect(page).to have_css("#custom_branch_name", visible: true)

      fill_in "Community Partner Name", with: "New Branch"

      expect do
        click_button "Sign Up"
      end.to change(LibraryLocation, :count).by(1)
    end

    scenario "registers without zipcode" do
      switch_to_subdomain(org.subdomain)

      visit login_path
      find("#signup_email").set(email)
      find("#signup_password").set(password)
      find("#user_profile_attributes_first_name").set(first_name)
      fill_in "user_password_confirmation", with: password

      expect(page).to have_css("#custom_branch_name", visible: false)

      select "Community Partner", from: :chzn

      expect(page).to have_css("#custom_branch_name", visible: true)

      fill_in "Community Partner Name", with: "New Branch"

      expect do
        click_button "Sign Up"
      end.to change(LibraryLocation, :count).by(1)
    end
  end

  context "accepts_programs", js: true, focus: true do
    let(:org) { create(:organization, accepts_programs: true) }

    scenario "registers" do
      switch_to_subdomain(org.subdomain)

      visit login_path
      find("#signup_email").set(email)
      find("#signup_password").set(password)
      find("#user_profile_attributes_first_name").set(first_name)
      find("#user_profile_attributes_last_name").set(last_name)
      find("#user_profile_attributes_zip_code").set(zip_code)
      fill_in "user_password_confirmation", with: password

      expect(page).to have_css("#user_program_id", visible: true)

      expect do
        click_button "Sign Up"
      end.to change(Profile, :count).by(1)
    end
  end

end
