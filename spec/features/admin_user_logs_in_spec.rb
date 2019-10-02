require "feature_helper"

feature "Admin user logs in" do
  context "traditional log in organization" do
    before(:each) do
      @org = create(:organization)
      Capybara.default_host = "http://chipublib.example.com"
      @user = create(:user, :first_time_user, organization: @org)
      @english = create(:language)
      @spanish = create(:spanish_lang)
      @user.add_role(:admin, @org)
      switch_to_subdomain("chipublib")
    end

    context "with invalid profile" do
      before(:each) do
        @user.profile.update_attribute(:first_name, nil)
      end

      scenario "is sent to profile page" do
        log_in_with @user.email, @user.password
        expect(current_path).to eq(profile_path)
      end

      scenario "can't navigate away from profile page with invalid profile" do
        log_in_with @user.email, @user.password
        visit new_admin_library_location_path
        expect(current_path).to eq(invalid_profile_path)
        expect(page).to have_content("You must have a valid profile before you can continue:")
        expect(page).to have_content("First name can't be blank")
      end
    end

    context "with no profile" do
      before(:each) do
        @user.profile.destroy
      end

      scenario "is prompted to update profile on first time sign in" do
        expect(@user.sign_in_count).to eq(0)
        log_in_with @user.email, @user.password
        expect(current_path).to eq(profile_path)
        expect(page).to have_content("This is the first time you have logged in, please update your profile.")
        click_link "Sign Out"
      end

      scenario "can't navigate away from profile page with no profile" do
        log_in_with @user.email, @user.password
        visit new_admin_library_location_path
        expect(current_path).to eq(invalid_profile_path)
        expect(page).to have_content("You must have a valid profile before you can continue:")
        expect(page).to have_content("First name can't be blank")
      end
    end

    context "with valid profile" do
      before(:each) do
        @user.profile = create(:profile)
        @user.reload
      end

      scenario "is sent to admin home page" do
        log_in_with @user.email, @user.password
        expect(current_path).to eq(admin_dashboard_index_path)
      end

      scenario "isn't prompted for quiz" do
        @user.update_attribute(:quiz_modal_complete, false)
        log_in_with @user.email, @user.password
        expect(page).not_to have_css("#quiz-start-modal")
      end
    end
  end

  context "for library card login organization" do
    let(:location) { create(:library_location) }
    let(:org) do
      create(:organization, :library_card_login, subdomain: "kclibrary", branches: true,
                       accepts_custom_branches: true, library_locations: [location])
    end
    let(:user) { build(:user, sign_in_count: 2) }

    before(:each) do
      user.add_role(:admin, org)
      user.update!(organization: org)
      @english = create(:language)
      @spanish = create(:spanish_lang)
      switch_to_subdomain(org.subdomain)
    end

    context "with no profile" do
      scenario "can sign in with email and password" do
        user.update(profile: nil)
        log_in_with(user.email, user.password, true)
        expect(current_path).to eq(profile_path)
      end
    end

    context "with valid profile" do
      scenario "can sign in with email and password" do
        log_in_with(user.email, user.password, true)
        expect(current_path).to eq(admin_dashboard_index_path)
      end
    end

  end
end
