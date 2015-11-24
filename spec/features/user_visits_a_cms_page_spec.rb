require "feature_helper"

feature "User visits account page" do

  before(:each) do
    @cms_page = FactoryGirl.create(:cms_page)
  end

  scenario "sees cms pages in the footer" do
    visit root_path
    expect(page).to have_link("A New Page")
  end

  scenario "can visit a cms page" do
    visit root_path
    click_link "A New Page"

    expect(current_path).to eq(cms_page_path(@cms_page))
  end

  scenario "can see title and body of cms page" do
    visit cms_page_path(@cms_page)

    expect(page).to have_content("A New Page")
    expect(page).to have_content("Look at that body")
  end

end
