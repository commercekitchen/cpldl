require "rails_helper"

describe Admin::DashboardController do
  before(:each) do
    @org = create(:organization, subdomain: "www")
    @request.host = "www.test.host"
    @user = create(:user, organization: @org)
    @english = create(:language)
    @spanish = create(:spanish_lang)
    sign_in @user
  end

  describe "#authorize_admin" do
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
      @user.add_role(:admin, @org)
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "get#pages_index" do
    before(:each) do
      @user.add_role(:admin, @org)
      @page1 = create(:cms_page, title: "Page 1", organization: @org)
      @page2 = create(:cms_page, title: "Page 2", organization: @org)
      @page3 = create(:cms_page, title: "Page 3", organization: @org)
    end

    it "assigns all cms_pages to @cms_pages" do
      get :pages_index
      expect(response).to have_http_status(:success)
      expect(assigns(:cms_pages)).to include(@page1, @page2, @page3)
      expect(assigns(:cms_pages).count).to eq(3)
    end
  end

  describe "get#users_index" do
    before(:each) do
      @user.add_role(:admin, @org)
      @user1 = create(:user, email: "one@example.com", organization: @org)
      @user2 = create(:user, email: "two@example.com", organization: @org)
      @user3 = create(:user, email: "three@example.com", organization: @org)
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
      @user.add_role(:admin, @org)
      @user1 = create(:user, email: "one@example.com", confirmed_at: nil)
    end

    it "should manually confirm user" do
      expect(@user1.confirmed?).to be false
      put :manually_confirm_user, { user_id: @user1.id }

      @user2 = User.find(@user1.id)
      expect(@user2.confirmed?).to be true
    end
  end
end
