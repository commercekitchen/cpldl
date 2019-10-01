require "feature_helper"

feature "User lands on subdomain" do
  let(:subdomain) { 'chipublib' }
  before do
    create(:spanish_lang)
    create(:language)
    @dpl = create(:organization, subdomain: subdomain, name: "Denver Public Library")
    switch_to_subdomain(subdomain)
  end

  context "and they fill out the registration form" do
    it "should log them in and display a message" do
      sign_up_with "valid@example.com", "password", "Alejandro", "12345"
      expect(User.last.subdomain).to eq(subdomain)
    end
  end

  context 'footer' do
    context 'subdomain footer logo' do
      it 'should have link-new_subdomain class for GA' do
        visit root_path
        expect(page).to have_css(".medium-logo.link-#{subdomain}")
      end
    end
  end
end
