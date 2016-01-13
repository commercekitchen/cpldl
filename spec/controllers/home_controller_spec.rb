require "rails_helper"

describe HomeController do

  before(:each) do
    @spanish = FactoryGirl.create(:spanish_lang)
    @english = FactoryGirl.create(:language)
  end

  describe "#index" do
    it "responds successfully" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
