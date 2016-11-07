require "feature_helper"

feature "Subdomain admin program management" do

  before(:each) do
    @spanish = create(:spanish_lang)
    @english = create(:language)
    @dpl = create(:organization, :accepts_programs, subdomain: "dpl")
    @dpl_admin = create(:user, organization: @dpl)
    @dpl_admin.add_role(:admin, @dpl)
    switch_to_subdomain("dpl")
    log_in_with @dpl_admin.email, @dpl_admin.password
  end

  scenario "subdomain admin can add a new program" do
    # TODO: finish testing new program addition
    visit admin_dashboard_index_path(subdomain: "dpl")
    click_on "Admin Dashboard"
    click_on "Manage Programs"
    # Expect no library program row
    click_on "Add a New Program"
    # Fill in program info
    # Save program
    # Expect new program on page
  end

  scenario "subdomain admin can manage existing programs" do
    # TODO: Test management of programs
    program = create(:program, organization: @dpl)
    pl = create(:program_location, program: program)
    visit admin_dashboard_index_path(subdomain: "dpl")
    click_on "Admin Dashboard"
    click_on "Manage Programs"
    click_on "Edit Program"
    # Assert current attribute
    # Change something
    # Assert attribute changed
  end
end