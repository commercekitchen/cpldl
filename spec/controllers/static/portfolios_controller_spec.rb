require "rails_helper"

describe Static::PortfoliosController do

  before(:each) do
    @www = create(:organization, subdomain: "www")
    @request.host = "www.digitallearn.org"
  end

  describe "#show" do

    it "returns a success" do
      get :show
      expect(response).to have_http_status(:success)
    end

    it "redirects to the www subdomain if a non-www version is requested" do
      @request.host = "npl.digitallearn.org"
      get :show
      expect(response).to redirect_to static_portfolio_url(subdomain: "www")
    end

  end

end
