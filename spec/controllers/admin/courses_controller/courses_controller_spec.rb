# frozen_string_literal: true

require 'rails_helper'

describe Admin::CoursesController do
  let(:org) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: org) }
  let(:category1) { FactoryBot.create(:category, organization: org) }
  let(:category2) { FactoryBot.create(:category, organization: org) }
  let!(:course1) { FactoryBot.create(:course_with_lessons, title: 'Course1', course_order: 1, category: category1, organization: org) }
  let!(:course2) { FactoryBot.create(:course, title: 'Course2', course_order: 2, category: category2, organization: org) }
  let!(:course3) { FactoryBot.create(:course, title: 'Course3', course_order: 3, organization: org) }

  let(:pla) { FactoryBot.create(:default_organization) }
  let(:pla_course) { FactoryBot.create(:course, organization: pla) }

  before(:each) do
    @request.host = "#{org.subdomain}.test.host"
    sign_in admin
  end

  describe 'GET #index' do
    before(:each) do
      get :index, params: { subdomain: 'chipublib' }
    end

    it 'assigns all courses as @courses' do
      expect(assigns(:courses)).to include(course1, course2, course3)
    end

    it 'only assigns correct number of courses' do
      expect(assigns(:courses).count).to eq(3)
    end

    it 'assigns category_ids' do
      expect(assigns(:category_ids)).to include(category1.id, category2.id)
    end

    it 'only assigns proper category ids' do
      expect(assigns(:category_ids).count).to eq(2)
    end

    it 'assigns uncategorized_courses' do
      expect(assigns(:uncategorized_courses)).to include(course3)
    end

    it 'only assigns uncategorized courses' do
      expect(assigns(:uncategorized_courses).count).to eq(1)
    end
  end

  describe 'GET #new' do
    it 'assigns a new course as @course' do
      get :new
      expect(assigns(:course)).to be_a_new(Course)
    end
  end

  describe 'GET #preview' do
    it 'assigns the requested course as @course' do
      get :preview, params: { course_id: pla_course.to_param }
      expect(assigns(:course)).to eq(pla_course)
    end

    it 'renders course show' do
      get :preview, params: { course_id: pla_course.to_param }
      expect(response).to render_template('courses/show')
    end
  end

  describe 'PATCH #update_pub_status' do
    it 'updates the status' do
      patch :update_pub_status, params: { course_id: course1.id.to_param, value: 'P' }
      course1.reload
      expect(course1.pub_status).to eq('P')
    end

    it 'updates the pub_date if status is published' do
      Timecop.freeze do
        patch :update_pub_status, params: { course_id: course1.id.to_param, value: 'A' }
        course1.reload
        expect(course1.pub_date).to be(nil)

        patch :update_pub_status, params: { course_id: course1.id.to_param, value: 'P' }
        course1.reload
        expect(course1.pub_date.to_i).to eq(Time.zone.now.to_i)
      end
    end
  end

  describe 'GET #edit' do
    let(:imported_course) { FactoryBot.create(:course, organization: org, parent: pla_course) }

    it 'assigns the requested course as @course' do
      get :edit, params: { id: course1.to_param }
      expect(assigns(:course)).to eq(course1)
    end

    it 'assigns imported_course instance variable to true if course is imported' do
      get :edit, params: { id: imported_course.to_param }
      expect(assigns(:imported_course)).to eq(true)
    end

    it 'assigns imported_course to false if course is original' do
      get :edit, params: { id: course1.to_param }
      expect(assigns(:imported_course)).to eq(false)
    end
  end

  describe 'POST #sort' do
    it 'should change course order' do
      order_params = { '0' => { id: course2.id, position: 1 }, '1' => { id: course1.id, position: 2 } }
      post :sort, params: { order: order_params }
      expect(course1.reload.course_order).to eq(2)
      expect(course2.reload.course_order).to eq(1)
    end
  end
end
