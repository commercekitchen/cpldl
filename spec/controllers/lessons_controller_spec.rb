# frozen_string_literal: true

# == Schema Information
#
# Table name: lessons
#
#  id                      :integer          not null, primary key
#  lesson_order            :integer
#  title                   :string(90)
#  duration                :integer
#  course_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string
#  summary                 :string(156)
#  story_line              :string(156)
#  seo_page_title          :string(90)
#  meta_desc               :string(156)
#  is_assessment           :boolean
#  story_line_file_name    :string
#  story_line_content_type :string
#  story_line_file_size    :integer
#  story_line_updated_at   :datetime
#  pub_status              :string
#

require 'rails_helper'

describe LessonsController do

  before(:each) do
    create(:default_organization)
    @request.host = 'www.test.host'
    @course1 = create(:course)
    @lesson1 = create(:lesson, title: 'Lesson1', lesson_order: 1, course: @course1)
    @lesson2 = create(:lesson, title: 'Lesson2', lesson_order: 2, course: @course1)
    @lesson3 = create(:lesson, title: 'Lesson3', lesson_order: 3, course: @course1)
    @course1.save

    @user = create(:user)
    sign_in @user
  end

  describe 'GET #index' do
    it 'assigns all lessons for a given course as @lessons' do
      get :index, params: { course_id: @course1.to_param }
      expect(assigns(:lessons).count).to eq(3)
      expect(assigns(:lessons).first).to eq(@lesson1)
      expect(assigns(:lessons).second).to eq(@lesson2)
      expect(assigns(:lessons).third).to eq(@lesson3)
    end

    it 'responds to json' do
      get :index, params: { course_id: @course1.to_param }, format: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested lesson as @lesson' do
      get :show, params: { course_id: @course1.to_param, id: @lesson1.id }
      expect(assigns(:lesson)).to eq(@lesson1)
    end

    it 'assigns the next lesson as @next_lesson' do
      get :show, params: { course_id: @course1.to_param, id: @lesson1.id }
      expect(assigns(:next_lesson)).to eq(@lesson2)
    end

    it 'creates a course_progress model, if not previously created' do
      expect(@user.course_progresses.count).to eq(0)
      get :show, params: { course_id: @course1.to_param, id: @lesson1.id }
      expect(@user.course_progresses.count).to eq(1)
    end

    it 'only creates the course_progress once' do
      get :show, params: { course_id: @course1.to_param, id: @lesson1.id }
      get :show, params: { course_id: @course1.to_param, id: @lesson1.id }
      expect(@user.course_progresses.count).to eq(1)
    end

    it 'allows the admin to change the title, and have the old title redirect to the new title' do
      old_url = @lesson1.friendly_id
      # @lesson1.slug = nil # Must set slug to nil for the friendly url to regenerate
      @lesson1.title = 'New Lesson Title'
      @lesson1.save

      get :show, params: { course_id: @course1.to_param, id: old_url }
      expect(assigns(:lesson)).to eq(@lesson1)
      expect(response).to have_http_status(:success)

      get :show, params: { course_id: @course1.to_param, id: @lesson1.friendly_id }
      expect(assigns(:lesson)).to eq(@lesson1)
    end

    it 'responds to json' do
      get :show, params: { course_id: @course1.to_param, id: @lesson2.id }, format: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #complete' do
    it 'marks a lesson for a given user as complete' do
      post :complete, params: { course_id: @course1.to_param, lesson_id: @lesson2.to_param }, format: :json
      progress = @user.course_progresses.find_by(course_id: @course1.id)
      expect(progress.completed_lessons.count).to eq(1)
      expect(JSON.parse(response.body)['redirect_path']).to eq(course_lesson_lesson_complete_path(@course1, @lesson2))
    end

    it 'marks a course as complete if the assessment was completed' do
      @lesson3.is_assessment = true
      @lesson3.save
      post :complete, params: { course_id: @course1.to_param, lesson_id: @lesson3.to_param }, format: :json
      progress = @user.course_progresses.find_by(course_id: @course1.id)
      expect(progress.complete?).to be true
    end

    it 'renders the course completion view if the assessment was completed' do
      @lesson3.is_assessment = true
      @lesson3.save
      post :complete, params: { course_id: @course1.to_param, lesson_id: @lesson3.to_param }, format: :json
      expect(JSON.parse(response.body)['redirect_path']).to eq(course_completion_path(@course1.to_param))
    end
  end

  describe 'GET #lesson_complete' do
    before do
      get :lesson_complete, params: { course_id: @course1, lesson_id: @lesson2 }
    end

    it 'should be a successful response' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns current lesson' do
      expect(assigns(:current_lesson)).to eq(@lesson2)
    end

    it 'assigns next lesson' do
      expect(assigns(:next_lesson)).to eq(@lesson3)
    end
  end
end
