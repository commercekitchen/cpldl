require "rails_helper"

describe HomeController do

  before(:each) do
    create(:organization, subdomain: "www")
    @request.host = "www.test.host"
    @spanish = create(:spanish_lang)
    @english = create(:language)
  end

  describe "#index" do
    it "responds successfully" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
