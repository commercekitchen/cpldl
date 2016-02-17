require "rails_helper"

describe "404 page" do
  it "is customized" do
    visit "/404"
    expect(page.status_code).to eq 404
    expect(page).to have_content("Woops! We couldn't find what you were looking for!")
  end
end

describe "500 page" do
  it "is customized" do
    visit "/500"
    expect(page.status_code).to eq 500
    expect(page).to have_content("Woops! Something went wrong here...sorry about that!")
  end
end
