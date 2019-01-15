require "rails_helper"

describe LoginController do

  before(:each) do
    create(:default_organization)
    @request.host = "www.test.host"
    @english = create(:language)
    @spanish = create(:spanish_lang)
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

end
