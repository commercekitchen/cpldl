require "rails_helper"

describe Trainer::DashboardController do
  before(:each) do
    @request.host = "chipublib.test.host"
    @org = create(:organization)
    @user = create(:user, organization: @org)
    @user.add_role(:user, @org)
    @english = create(:language)
    @spanish = create(:spanish_lang)
    sign_in @user
  end

  describe "#authorize_admin" do
    it "redirects non trainer users to the root of the site" do
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

    it "allows trainer users" do
      @user.add_role(:trainer, @org)
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "get#index" do
    before(:each) do
      @user.add_role(:trainer, @org)
      @user1 = create(:user, email: "one@example.com")
      @user2 = create(:user, email: "two@example.com")
      @user3 = create(:user, email: "three@example.com")
      @user1.add_role(:user, @org)
      @user2.add_role(:user, @org)
      @user3.add_role(:user, @org)
      sign_in @user
    end

    it "assigns all users as @users" do
      get :index, {}
      expect(response).to have_http_status(:success)
      expect(assigns(:users)).to include(@user, @user1, @user2, @user3)
      expect(assigns(:users).count).to eq(4)
    end

    it "assigns all users as @users with an empty params" do
      get :index, {}
      expect(assigns(:users)).to include(@user, @user1, @user2, @user3)
    end

    it "assigns search results to @users" do
      get :index, { search: "two" }
      expect(assigns(:users)).to eq([@user2])
    end
  end

  describe "put#trainer_dashboard_manually_confirm_user" do
    before(:each) do
      @user.add_role(:trainer, @org)
      @user1 = FactoryGirl.create(:user, email: "one@example.com", confirmed_at: nil)
    end

    it "should manually confirm user" do
      expect(@user1.confirmed?).to be false
      put :manually_confirm_user, { user_id: @user1.id }

      @user2 = User.find(@user1.id)
      expect(@user2.confirmed?).to be true
    end
  end
end
