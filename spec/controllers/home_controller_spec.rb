require "rails_helper"

describe HomeController do

  describe "#index" do
    it "responds successfully" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
