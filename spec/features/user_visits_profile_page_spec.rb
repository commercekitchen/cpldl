require "feature_helper"

feature "Registered user visits account page" do

  context "belongs to non-npl subdomain" do

    before(:each) do
      switch_to_subdomain("chipublib")
      @organization = create(:organization)
      @user = create(:user, organization: @organization)
      Language.all.each(&:destroy)
      @english = create(:language)
      @spanish = create(:spanish_lang)
      login_as(@user)
    end

    scenario "can view their account options" do
      visit account_path
      expect(page).to have_content("Change Login Information")
      expect(page).to have_content("Update Profile")
      expect(page).to have_content("My Completed Courses")
    end

    scenario "can change login information" do
      original_encrypted_pw = @user.encrypted_password
      visit account_path
      fill_in "Email", with: "alex@commercekitchen.com"
      fill_in "user_password", with: "password"
      fill_in "user_password_confirmation", with: "password"
      click_button "Save"

      @user.reload
      expect(@user.unconfirmed_email).to eq("alex@commercekitchen.com")
      expect(@user.encrypted_password).not_to eq original_encrypted_pw
    end

    scenario "can update their profile information" do
      visit profile_path
      fill_in "First Name", with: "Alex"
      fill_in "Zip Code", with: "12345"
      select("English", from: "profile_language_id")
      click_button "Save"

      @user.reload
      expect(@user.profile.first_name).to eq("Alex")
      expect(@user.profile.zip_code).to eq("12345")
      expect(@user.profile.language.name).to eq("English")
    end

    scenario "can view completed courses" do
      # visit courses_completed_path
    end

  end

  context "belongs to Nashville subdomain" do

    before(:each) do
      @npl_organization = create(:organization, :accepts_programs, subdomain: "npl")
      @npl_user = create(:user, organization: @npl_organization)
      Language.all.each(&:destroy)
      @english = create(:language)
      @spanish = create(:spanish_lang)
      switch_to_subdomain("npl")
      login_as(@npl_user)
    end

    scenario "can view their account options" do
      visit account_path
      expect(page).to have_content("Change Login Information")
      expect(page).to have_content("Update Profile")
      expect(page).to have_content("My Completed Courses")
    end

    scenario "can change login information" do
      original_encrypted_pw = @npl_user.encrypted_password
      visit account_path
      fill_in "Email", with: "alex@commercekitchen.com"
      fill_in "user_password", with: "password"
      fill_in "user_password_confirmation", with: "password"
      click_button "Save"

      @npl_user.reload
      expect(@npl_user.unconfirmed_email).to eq("alex@commercekitchen.com")
      expect(@npl_user.encrypted_password).not_to eq original_encrypted_pw
    end

    scenario "can update profile information" do
      # TODO: add npl specific fields
      visit profile_path
      fill_in "First Name", with: "Alex"
      fill_in "Last Name", with: "Monroe"
      fill_in "Zip Code", with: "12345"
      select("English", from: "profile_language_id")
      click_button "Save"

      @npl_user.reload
      expect(@npl_user.profile.first_name).to eq("Alex")
      expect(@npl_user.profile.last_name).to eq("Monroe")
      expect(@npl_user.profile.zip_code).to eq("12345")
      expect(@npl_user.profile.language.name).to eq("English")
    end

    scenario "last name required" do
      visit profile_path
      fill_in "First Name", with: "Alex"
      click_button "Save"
      expect(page).to have_content "Last name can't be blank"
    end

  end

end
