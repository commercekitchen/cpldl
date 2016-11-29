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

  describe "GET #import_courses" do
    before do
      @user.add_role(:admin, @org)
      @other_org = create(:organization)
      @dl_course1 = create(:course, title: "Course1", subsite_course: true)
      @dl_course2 = create(:course, title: "Course2", subsite_course: true)
      @dl_course3 = create(:course, title: "Course3", subsite_course: true)
      @dl_course4 = create(:course, title: "Course4", subsite_course: true)
      @dl_course5 = create(:course, title: "Course5", subsite_course: true)
      @archived_course = create(:course, title: "Archived Cource", subsite_course: true, pub_status: "A")
      @course1 = create(:course, title: "Course1", subsite_course: false, parent_id: @dl_course1.id)
      @course2 = create(:course, title: "Course2", subsite_course: false, parent_id: @dl_course2.id)
      @course3 = create(:course, title: "Course3", subsite_course: false, parent_id: @dl_course3.id)
      @archived_subdomain_course = create(:course, title: "ArchSubCourse", subsite_course: false, parent_id: @dl_course4.id, pub_status: "A")
      @draft_subdomain_course = create(:course, title: "DraftSubCourse", subsite_course: false, parent_id: @dl_course5.id, pub_status: "D")
      @org_course1 = create(:organization_course, organization_id: @org.id, course_id: @course1.id)
      @org_course2 = create(:organization_course, organization_id: @other_org.id, course_id: @course2.id)
      @org_course3 = create(:organization_course, organization_id: @org.id, course_id: @course3.id)
      @org_course4 = create(:organization_course, organization_id: @other_org.id, course_id: @course3.id)
      @org_course5 = create(:organization_course, organization_id: @org.id, course_id: @archived_subdomain_course.id)
      @org_course6 = create(:organization_course, organization_id: @org.id, course_id: @draft_subdomain_course.id)
    end

    it "should correctly assign previously imported courses" do
      get :import_courses
      expect(assigns(:previously_imported_ids)).to eq([@dl_course1.id, @dl_course3.id, @dl_course5.id])
    end

    it "should correctly assign importable courses" do
      get :import_courses
      expect(assigns(:importable_courses)).to eq([@dl_course2, @dl_course4])
    end
  end
end
