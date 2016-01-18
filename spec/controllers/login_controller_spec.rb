require "rails_helper"

describe LoginController do

  before(:each) do
    @english = FactoryGirl.create(:language)
    @spanish = FactoryGirl.create(:spanish_lang)
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

end
