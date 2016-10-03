require "feature_helper"

feature "Admin user logs in" do

  context "test forced password changing" do

    before(:each) do
      @org = create(:organization)
      Capybara.default_host = "http://chipublib.example.com"
      @user = create(:user, organization: @org)
      @english = create(:language)
      @spanish = create(:spanish_lang)
      @user.add_role(:admin, @org)
      switch_to_subdomain("chipublib")
    end

    scenario "is prompted to change password on first time" do
      expect(@user.sign_in_count).to eq(0)
      log_in_with @user.email, @user.password
      expect(current_path).to eq(profile_path)
      expect(page).to have_content("This is the first time you have logged in, please change your password.")
      click_link "Sign Out"
    end

    scenario "is not prompted to change password after first time" do
      @user.sign_in_count = 1
      @user.save
      log_in_with @user.email, @user.password
      expect(current_path).to eq(admin_dashboard_index_path)
      click_link "Sign Out"
    end

  end

end
