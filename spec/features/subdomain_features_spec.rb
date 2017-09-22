require "feature_helper"

feature "User lands on subdomain" do
  before do
    create(:spanish_lang)
    create(:language)
    @dpl = create(:organization, subdomain: "dpl", name: "Denver Public Library")
    switch_to_subdomain(@dpl.subdomain)
  end

  context "and they fill out the registration form" do
    it "should log them in and display a message" do
      sign_up_with "valid@example.com", "password", "Alejandro", "12345"
      expect(User.last.subdomain).to eq(@dpl.subdomain)
    end
  end

end
