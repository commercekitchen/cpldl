# frozen_string_literal: true

require 'rails_helper'

describe Admin::DashboardController do
  let(:org) { FactoryBot.create(:default_organization) }
  let(:other_org) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: org) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: org) }

  before(:each) do
    @request.host = "#{org.subdomain}.test.host"
  end

  describe '#authorize_admin' do
    it 'redirects non admin users to the root of the site' do
      sign_in user
      get :index
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it 'redirects nil users to the root of the site' do
      get :index
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it 'allows admin users' do
      sign_in admin
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #import_courses' do
    let(:dl_course1) { FactoryBot.create(:course, title: 'Course1', subsite_course: true) }
    let(:dl_course2) { FactoryBot.create(:course, title: 'Course2', subsite_course: true) }
    let(:dl_course3) { FactoryBot.create(:course, title: 'Course3', subsite_course: true) }
    let(:dl_course4) { FactoryBot.create(:course, title: 'Course4', subsite_course: true) }
    let(:dl_course5) { FactoryBot.create(:course, title: 'Course5', subsite_course: true) }
    let!(:archived_course) { FactoryBot.create(:course, title: 'Archived Cource', subsite_course: true, pub_status: 'A') }
    let!(:course1) { FactoryBot.create(:course, title: 'Course1', subsite_course: false, parent_id: dl_course1.id, organization: org) }
    let!(:course2) { FactoryBot.create(:course, title: 'Course2', subsite_course: false, parent_id: dl_course2.id, organization: other_org) }
    let!(:course3) { FactoryBot.create(:course, title: 'Course3', subsite_course: false, parent_id: dl_course3.id, organization: org) }
    let!(:archived_subdomain_course) { FactoryBot.create(:course, title: 'ArchSubCourse', subsite_course: false, parent_id: dl_course4.id, pub_status: 'A', organization: org) }
    let!(:draft_subdomain_course) { FactoryBot.create(:course, title: 'DraftSubCourse', subsite_course: false, parent_id: dl_course5.id, pub_status: 'D', organization: org) }

    before do
      sign_in admin
    end

    it 'should correctly assign previously imported courses' do
      get :import_courses
      expect(assigns(:previously_imported_ids) - [dl_course1.id, dl_course3.id, dl_course5.id]).to eq([])
    end

    it 'should correctly assign importable courses' do
      get :import_courses
      expect(assigns(:importable_courses)).to eq([dl_course2, dl_course4])
    end
  end

  describe 'POST #add_imported_course' do
    let(:org_category) { FactoryBot.create(:category, organization: org) }
    let(:other_org_cat1) { FactoryBot.create(:category, organization: other_org) }
    let(:other_org_cat2) { FactoryBot.create(:category, name: org_category.name.upcase, organization: other_org) }
    let!(:importable_course1) { FactoryBot.create(:course_with_lessons, subsite_course: true, category: other_org_cat1) }
    let!(:importable_course2) { FactoryBot.create(:course_with_lessons, subsite_course: true, category: other_org_cat2) }
    let!(:importable_course3) { FactoryBot.create(:course_with_lessons, subsite_course: true) }

    before do
      sign_in admin
    end

    context 'new category name' do
      it 'should create new course' do
        expect do
          post :add_imported_course, params: { course_id: importable_course1.id }
        end.to change(Course, :count).by(1)
      end

      it 'should create new subdomain course with new category with same name as imported course' do
        post :add_imported_course, params: { course_id: importable_course1.id }
        course_category = org.courses.last.category
        expect(course_category.id).not_to eq(importable_course1.category.id)
        expect(course_category.name).to eq(importable_course1.category.name)
        expect(course_category.organization_id).to eq(org.id)
      end

      it "should create new category if category name doesn't exist for org" do
        expect do
          post :add_imported_course, params: { course_id: importable_course1.id }
        end.to change(Category, :count).by(1)
      end
    end

    context 'existing category name, regardelss of case' do
      it 'should create a new course' do
        expect do
          post :add_imported_course, params: { course_id: importable_course2.id }
        end.to change(Course, :count).by(1)
      end

      it 'should not create a new category' do
        expect do
          post :add_imported_course, params: { course_id: importable_course2.id }
        end.not_to change(Category, :count)
      end

      it 'should add existing category to course if name does exist for org' do
        post :add_imported_course, params: { course_id: importable_course2.id }
        course_category = org.courses.last.category
        expect(course_category.id).to eq(org_category.id)
        expect(course_category.name).to eq(org_category.name)
        expect(course_category.organization_id).to eq(org.id)
      end
    end

    context 'uncategorized import' do
      it 'should create a new course' do
        expect do
          post :add_imported_course, params: { course_id: importable_course3.id }
        end.to change(Course, :count).by(1)
      end

      it 'should not create a new category' do
        expect do
          post :add_imported_course, params: { course_id: importable_course3.id }
        end.not_to change(Category, :count)
      end

      it 'should nullify course category info' do
        post :add_imported_course, params: { course_id: importable_course3.id }
        expect(org.courses.last.category_id).to be_nil
        expect(org.courses.last.category).to be_nil
      end
    end
  end
end
