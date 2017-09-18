require "feature_helper"

feature "Annonymous visits static pages" do

  before(:each) do
    create(:organization, subdomain: "www")
  end

  scenario "can visit the customization page" do
    visit static_customization_path
    expect(current_path).to eq(static_customization_path)
  end

end
