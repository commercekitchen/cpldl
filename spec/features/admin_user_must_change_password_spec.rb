require "feature_helper"

feature "Super admin user logs in" do

  context "for the first time" do

    scenario "is prompted to change password" do
      user = FactoryGirl.create(:user)
      user.add_role(:super)
      expect(user.sign_in_count).to eq(0)
      log_in_with user.email, user.password
      expect(current_path).to eq(profile_path)
      expect(page).to have_content("This is the first time you have logged in, please change your password.")
    end

  end

  context "after the first time" do

    scenario "is not prompted to change password" do
      user = FactoryGirl.create(:user)
      user.add_role(:super)
      user.sign_in_count = 1
      user.save
      log_in_with user.email, user.password
      expect(current_path).to eq(administrators_dashboard_index_path)
    end

  end

end
