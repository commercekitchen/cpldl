require "feature_helper"

feature "Admin user logs in" do
  context "force profile update" do
    before(:each) do
      @org = create(:organization)
      Capybara.default_host = "http://chipublib.example.com"
      @user = create(:user, organization: @org)
      @user.profile.destroy
      @english = create(:language)
      @spanish = create(:spanish_lang)
      @user.add_role(:admin, @org)
      switch_to_subdomain("chipublib")
    end

    scenario "is prompted to update profile" do
      expect(@user.sign_in_count).to eq(0)
      log_in_with @user.email, @user.password
      expect(current_path).to eq(profile_path)
      click_link "Sign Out"
    end
  end
end
