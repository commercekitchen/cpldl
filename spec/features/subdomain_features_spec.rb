require "feature_helper"

feature "User lands on subdomain" do
  before do
    create(:spanish_lang)
    create(:language)
    @dpl = create(:organization,
                  subdomain: "dpl",
                  name: "Denver Public Library")
    switch_to_subdomain(@dpl.subdomain)
  end


  context "and they fill out the registration form" do
    it "should log them in and display a message" do
      sign_up_with "valid@example.com", "password", "Alejandro", "12345"
      expect(page).to have_content("A message with a confirmation link has been sent \
        to your email address. Please follow the link to activate your account.")
      expect(User.last.subdomain).to eq(@dpl.subdomain)
    end
  end

  context "and the subdomain requires a library branch" do
    it "displays the available organization branches" do

    end
  end

  context "and the subdomain has special info in confirmation email" do

  end

  context "and it is the incorrect subdomain" do

  end

end
