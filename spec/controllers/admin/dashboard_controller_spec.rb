# frozen_string_literal: true

require 'rails_helper'

describe Admin::DashboardController do
  before(:each) do
    @org = create(:default_organization)
    @request.host = 'www.test.host'
    @user = create(:user, organization: @org)
    @english = create(:language)
    @spanish = create(:spanish_lang)
    sign_in @user
  end

  describe '#authorize_admin' do
    it 'redirects non admin users to the root of the site' do
      get :index
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it 'redirects nil users to the root of the site' do
      @user = nil
      get :index
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it 'allows admin users' do
      @user.add_role(:admin, @org)
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'get#pages_index' do
    before(:each) do
      @user.add_role(:admin, @org)
      @page1 = create(:cms_page, title: 'Page 1', organization: @org)
      @page2 = create(:cms_page, title: 'Page 2', organization: @org)
      @page3 = create(:cms_page, title: 'Page 3', organization: @org)
    end

    it 'assigns all cms_pages to @cms_pages' do
      get :pages_index
      expect(response).to have_http_status(:success)
      expect(assigns(:cms_pages)).to include(@page1, @page2, @page3)
      expect(assigns(:cms_pages).count).to eq(3)
    end
  end

  describe 'get#users_index' do
    before(:each) do
      @user.add_role(:admin, @org)
      @user1 = create(:user, email: 'one@example.com', organization: @org)
      @user2 = create(:user, email: 'two@example.com', organization: @org)
      @user3 = create(:user, email: 'three@example.com', organization: @org)
      @user1.add_role(:user, @org)
      @user2.add_role(:user, @org)
      @user3.add_role(:user, @org)
    end

    it 'assigns all users as @users' do
      get :users_index
      expect(response).to have_http_status(:success)
      expect(assigns(:users)).to include(@user, @user1, @user2, @user3)
      expect(assigns(:users).count).to eq(4)
    end

    it 'assigns all users as @users with an empty params' do
      get :users_index, params: {}
      expect(assigns(:users)).to include(@user, @user1, @user2, @user3)
    end

    it 'assigns search results to @users' do
      get :users_index, params: { search: 'two' }
      expect(assigns(:users)).to eq([@user2])
    end
  end

  describe 'GET #import_courses' do
    before do
      @user.add_role(:admin, @org)
      @other_org = create(:organization)
      @dl_course1 = create(:course, title: 'Course1', subsite_course: true)
      @dl_course2 = create(:course, title: 'Course2', subsite_course: true)
      @dl_course3 = create(:course, title: 'Course3', subsite_course: true)
      @dl_course4 = create(:course, title: 'Course4', subsite_course: true)
      @dl_course5 = create(:course, title: 'Course5', subsite_course: true)
      @archived_course = create(:course, title: 'Archived Cource', subsite_course: true, pub_status: 'A')
      @course1 = create(:course, title: 'Course1', subsite_course: false, parent_id: @dl_course1.id, organization: @org)
      @course2 = create(:course, title: 'Course2', subsite_course: false, parent_id: @dl_course2.id, organization: @other_org)
      @course3 = create(:course, title: 'Course3', subsite_course: false, parent_id: @dl_course3.id, organization: @org)
      @archived_subdomain_course = create(:course, title: 'ArchSubCourse', subsite_course: false, parent_id: @dl_course4.id, pub_status: 'A', organization: @org)
      @draft_subdomain_course = create(:course, title: 'DraftSubCourse', subsite_course: false, parent_id: @dl_course5.id, pub_status: 'D', organization: @org)
    end

    it 'should correctly assign previously imported courses' do
      get :import_courses
      expect(assigns(:previously_imported_ids) - [@dl_course1.id, @dl_course3.id, @dl_course5.id]).to eq([])
    end

    it 'should correctly assign importable courses' do
      get :import_courses
      expect(assigns(:importable_courses)).to eq([@dl_course2, @dl_course4])
    end
  end

  describe 'POST #add_imported_course' do
    before do
      @user.add_role(:admin, @org)
      @other_org = create(:organization)
      @org_category = create(:category, organization: @org)
      @other_org_cat1 = create(:category, organization: @other_org)
      @other_org_cat2 = create(:category, name: @org_category.name.upcase, organization: @other_org)
      @importable_course1 = create(:course_with_lessons, subsite_course: true, category: @other_org_cat1)
      @importable_course2 = create(:course_with_lessons, subsite_course: true, category: @other_org_cat2)
      @importable_course3 = create(:course_with_lessons, subsite_course: true)

      sign_in @user
    end

    context 'new category name' do
      it 'should create new course' do
        expect do
          post :add_imported_course, params: { course_id: @importable_course1.id }
        end.to change(Course, :count).by(1)
      end

      it 'should create new subdomain course with new category with same name as imported course' do
        post :add_imported_course, params: { course_id: @importable_course1.id }
        course_category = @org.courses.last.category
        expect(course_category.id).not_to eq(@importable_course1.category.id)
        expect(course_category.name).to eq(@importable_course1.category.name)
        expect(course_category.organization_id).to eq(@org.id)
      end

      it "should create new category if category name doesn't exist for org" do
        expect do
          post :add_imported_course, params: { course_id: @importable_course1.id }
        end.to change(Category, :count).by(1)
      end
    end

    context 'existing category name, regardelss of case' do
      it 'should create a new course' do
        expect do
          post :add_imported_course, params: { course_id: @importable_course2.id }
        end.to change(Course, :count).by(1)
      end

      it 'should not create a new category' do
        expect do
          post :add_imported_course, params: { course_id: @importable_course2.id }
        end.not_to change(Category, :count)
      end

      it 'should add existing category to course if name does exist for org' do
        post :add_imported_course, params: { course_id: @importable_course2.id }
        course_category = @org.courses.last.category
        expect(course_category.id).to eq(@org_category.id)
        expect(course_category.name).to eq(@org_category.name)
        expect(course_category.organization_id).to eq(@org.id)
      end
    end

    context 'uncategorized import' do
      it 'should create a new course' do
        expect do
          post :add_imported_course, params: { course_id: @importable_course3.id }
        end.to change(Course, :count).by(1)
      end

      it 'should not create a new category' do
        expect do
          post :add_imported_course, params: { course_id: @importable_course3.id }
        end.not_to change(Category, :count)
      end

      it 'should nullify course category info' do
        post :add_imported_course, params: { course_id: @importable_course3.id }
        expect(@org.courses.last.category_id).to be_nil
        expect(@org.courses.last.category).to be_nil
      end
    end
  end
end
