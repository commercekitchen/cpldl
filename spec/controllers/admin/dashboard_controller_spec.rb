require "rails_helper"

describe Admin::DashboardController do

  describe "#authorize_admin" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "redirects non admin users to the root of the site" do
      get :index
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "redirects nil users to the root of the site" do
      @user = nil
      get :index
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "allows admin users" do
      @user.add_role(:admin)
      get :index
      expect(response).to have_http_status(:success)
    end

  end
end
