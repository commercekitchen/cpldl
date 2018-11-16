require "feature_helper"

feature "User logs in" do

  before(:each) do
    @org = create(:organization)
    @spanish = create(:spanish_lang)
    @english = create(:language)
    switch_to_subdomain("chipublib")
  end

  scenario "with valid email and password" do
    user = create(:user, organization: @org)
    user.add_role(:user, @org)
    log_in_with(user.email, user.password)
    expect(current_path).to eq(root_path)
    expect(page).to_not have_content("Signed in successfully.")
    expect(page).to have_content("Use a computer to do almost anything!")
    expect(page).to have_content(
      "Choose a course below to start learning, or visit My Courses to view your customized learning plan."
    )
  end

  scenario "with invalid or blank email" do
    log_in_with "", "password"

    expect(page).to have_content("Invalid email or password.")

    log_in_with "not@real.com", "password"
    expect(page).to have_content("Invalid email or password.")
  end

  scenario "with blank password" do
    log_in_with "valid@example.com", ""
    expect(page).to have_content("Invalid email or password.")

    log_in_with "valid@example.com", "no correct pwd"
    expect(page).to have_content("Invalid email or password.")
  end

  scenario "first time login non-program org" do
    user = create(:first_time_user, organization: @org)
    past_time = 10.minutes.ago
    user.profile.update_attributes({ created_at: past_time, updated_at: past_time })
    log_in_with(user.email, user.password)
    expect(current_path).to eq(profile_path)

    click_on "Save"
    user.profile.reload

    expect(current_path).to eq(courses_quiz_path)
    visit profile_path
    click_on "Save"

    expect(current_path).to eq(profile_path)
  end

  scenario "first time login with program org, with course recommendations" do
    @npl = create(:organization, :accepts_programs, subdomain: "npl")
    @npl_profile = create(:profile, :with_last_name)
    @npl_user = create(:first_time_user, organization: @npl, profile: @npl_profile)
    switch_to_subdomain("npl")
    log_in_with(@npl_user.email, @npl_user.password)

    expect(current_path).to eq(profile_path)

    fill_in "Last Name", with: Faker::Name.last_name

    click_on "Save"

    expect(current_path).to eq(courses_quiz_path)
  end

  scenario "first time login with program org, no course recommendations" do
    @npl = create(:organization, :accepts_programs, subdomain: "npl")
    @npl_profile = create(:profile, :with_last_name)
    @npl_user = create(:first_time_user, organization: @npl, profile: @npl_profile)
    switch_to_subdomain("npl")
    log_in_with(@npl_user.email, @npl_user.password)

    expect(current_path).to eq(profile_path)

    fill_in "Last Name", with: Faker::Name.last_name
    choose "profile_opt_out_of_recommendations_true"
    click_on "Save"

    expect(current_path).to eq(root_path)
  end

  scenario "with an invalid profile for a program org" do
    @npl = create(:organization, :accepts_programs, subdomain: "npl")
    @npl_profile = create(:profile, :with_last_name)
    @npl_user = create(:user, organization: @npl, profile: @npl_profile)
    @npl_profile.update_attribute(:last_name, nil)
    switch_to_subdomain("npl")
    log_in_with(@npl_user.email, @npl_user.password)

    expect(current_path).to eq(profile_path)
  end

  scenario "with a valid profile for a program org" do
    @npl = create(:organization, :accepts_programs, subdomain: "npl")
    @npl_profile = create(:profile, :with_last_name)
    @npl_user = create(:user, organization: @npl, profile: @npl_profile)
    switch_to_subdomain("npl")
    log_in_with(@npl_user.email, @npl_user.password)

    expect(current_path).to eq(root_path)
  end

end
