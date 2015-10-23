require "feature_helper"

feature "Admin user clicks through each page" do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @user.add_role(:admin)
    log_in_with @user.email, @user.password
  end

  scenario "can visit each link in the header" do
    visit admin_dashboard_index_path
    expect(page).to have_content("Hi Admin!")

    visit admin_dashboard_index_path
    within(:css, ".header-logged-in") do
      click_link "Admin Dashboard"
    end
    expect(current_path).to eq(admin_dashboard_index_path)

    visit admin_dashboard_index_path
    within(:css, ".header-logged-in") do
      click_link "Sign Out"
    end
    expect(current_path).to eq(root_path)
    expect(page).to have_content("Signed out successfully.")
  end

end
