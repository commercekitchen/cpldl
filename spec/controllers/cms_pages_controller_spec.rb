require "rails_helper"

describe CmsPagesController do
  before(:each) do
    @cms_page = FactoryGirl.create(:cms_page)
  end

  describe "GET #show" do
    it "assigns the requested page (by id) as @cms_page" do
      get :show, id: @cms_page.to_param
      expect(assigns(:cms_page)).to eq(@cms_page)
    end

    it "assigns the requested cms_page (by friendly id) as @cms_page" do
      get :show, id: @cms_page.friendly_id
      expect(assigns(:cms_page)).to eq(@cms_page)
    end

    it "allows the admin to change the title, and have the old title redirect to the new title" do
      old_url = @cms_page.friendly_id
      @cms_page.slug = nil # Must set slug to nil for the friendly url to regenerate
      @cms_page.title = "New Title"
      @cms_page.save

      get :show, id: old_url
      expect(assigns(:cms_page)).to eq(@cms_page)
      expect(response).to have_http_status(:redirect)

      get :show, id: @cms_page.friendly_id
      expect(assigns(:cms_page)).to eq(@cms_page)
    end
  end
end
