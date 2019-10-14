require "feature_helper"

feature "Anonymous user submits contact form" do

  before(:each) do
    create(:default_organization)
    switch_to_subdomain("www")
    create(:spanish_lang)
    create(:language)
  end

  scenario "fills out all required information" do
    visit new_contact_path(subdomain: "www")
    fill_in "contact[first_name]", with: "Alan"
    fill_in "contact[last_name]", with: "Turing"
    fill_in "contact[organization]", with: "NY Public Library"
    fill_in "contact[city]", with: "New York"
    select "New York"
    fill_in "contact[email]", with: "alan@ny.org"
    fill_in "contact[phone]", with: "(555) 123 - 1234"
    fill_in "contact[comments]", with: "I'd like to know about XYZ"
    click_button "Submit"
    expect(current_path).to eq root_path
    expect(page).to have_content "Thank you for your interest!"
  end

  scenario "displays errors if not all required fields are entered" do
    visit new_contact_path(subdomain: "www")
    click_button "Submit"
    expect(current_path).to eq contact_index_path
    expect(page).to have_content "The following errors"
  end

end
