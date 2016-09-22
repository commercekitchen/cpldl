require "rails_helper"

describe Admin::DashboardController do
  before(:each) do
    @request.host = "www.test.host"
    @user = FactoryGirl.create(:user)
    @org = FactoryGirl.create(:organization)
    @user.add_role(:admin, @org)
    @english = FactoryGirl.create(:language)
    @spanish = FactoryGirl.create(:spanish_lang)
    sign_in @user
  end

  describe "#authorize_admin" do
    # randomly fails, but click test works
    xit "redirects non admin users to the root of the site" do
      get :index
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    xit "redirects nil users to the root of the site" do
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

  describe "get#pages_index" do
    before(:each) do
      @user.add_role(:admin)
      @page1 = FactoryGirl.create(:cms_page, title: "Page 1")
      @page2 = FactoryGirl.create(:cms_page, title: "Page 2")
      @page3 = FactoryGirl.create(:cms_page, title: "Page 3")
    end
    # For some reason, works when this file is run, but not all files. Grr.
    xit "assigns all cms_pages to @cms_pages" do
      get :pages_index
      expect(response).to have_http_status(:success)
      expect(assigns(:cms_pages)).to include(@page1, @page2, @page3)
      expect(assigns(:cms_pages).count).to eq(3)
    end
  end

  describe "get#users_index" do
    before(:each) do
      @user.add_role(:admin)
      @user1 = FactoryGirl.create(:user, email: "one@example.com")
      @user2 = FactoryGirl.create(:user, email: "two@example.com")
      @user3 = FactoryGirl.create(:user, email: "three@example.com")
      @user1.add_role(:user, @org)
      @user2.add_role(:user, @org)
      @user3.add_role(:user, @org)
    end

    it "assigns all users as @users" do
      get :users_index
      expect(response).to have_http_status(:success)
      expect(assigns(:users)).to include(@user, @user1, @user2, @user3)
      expect(assigns(:users).count).to eq(4)
    end

    it "assigns all users as @users with an empty params" do
      get :users_index, {}
      expect(assigns(:users)).to include(@user, @user1, @user2, @user3)
    end

    it "assigns search results to @users" do
      get :users_index, { search: "two" }
      expect(assigns(:users)).to eq([@user2])
    end
  end

  describe "put#admin_dashboard_manually_confirm_user" do
    before(:each) do
      @user.add_role(:admin)
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
