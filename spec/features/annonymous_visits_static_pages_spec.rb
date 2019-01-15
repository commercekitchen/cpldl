require "feature_helper"

feature "Annonymous visits static pages" do
  before(:each) do
    create(:default_organization)
  end

  scenario "can visit the customization page" do
    page = create(:cms_page, title: "Pricing & Features")
    visit cms_page_path(page)
    expect(current_path).to eq(cms_page_path(page))
  end

  scenario "can visit the overview page" do
    page = create(:cms_page, title: "Get DigitalLearn for Your Library")
    visit cms_page_path(page)
    expect(current_path).to eq(cms_page_path(page))
  end

  scenario "can visit the portfolio page" do
    page = create(:cms_page, title: "See Our Work In Action")
    visit cms_page_path(page)
    expect(current_path).to eq(cms_page_path(page))
  end
end
