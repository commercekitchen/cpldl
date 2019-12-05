# frozen_string_literal: true

require 'rails_helper'

describe LessonsController do
  let(:org) { FactoryBot.create(:default_organization) }
  let(:user) { FactoryBot.create(:user, organization: org) }
  let(:course) { FactoryBot.create(:course) }
  let!(:lesson1) { FactoryBot.create(:lesson, lesson_order: 1, course: course) }
  let!(:lesson2) { FactoryBot.create(:lesson, lesson_order: 2, course: course) }
  let!(:lesson3) { FactoryBot.create(:lesson, lesson_order: 3, course: course) }

  before(:each) do
    @request.host = 'www.test.host'
    sign_in user
  end

  describe 'GET #show' do
    it 'assigns the requested lesson as @lesson' do
      get :show, params: { course_id: course.to_param, id: lesson1.id }
      expect(assigns(:lesson)).to eq(lesson1)
    end

    it 'assigns the next lesson as @next_lesson' do
      get :show, params: { course_id: course.to_param, id: lesson1.id }
      expect(assigns(:next_lesson)).to eq(lesson2)
    end

    it 'creates a course_progress model, if not previously created' do
      expect do
        get :show, params: { course_id: course.to_param, id: lesson1.id }
      end.to change(user.course_progresses, :count).by(1)
    end

    it 'only creates the course_progress once' do
      get :show, params: { course_id: course.to_param, id: lesson1.id }
      expect do
        get :show, params: { course_id: course.to_param, id: lesson1.id }
      end.to_not change(user.course_progresses, :count)
    end

    it 'finds correct lesson from old title' do
      old_url = lesson1.friendly_id
      lesson1.update(title: 'New Lesson Title')

      get :show, params: { course_id: course.to_param, id: old_url }
      expect(assigns(:lesson)).to eq(lesson1)
      expect(response).to have_http_status(:success)

      get :show, params: { course_id: course.to_param, id: lesson1.friendly_id }
      expect(assigns(:lesson)).to eq(lesson1)
    end

    it 'responds to json' do
      get :show, params: { course_id: course.to_param, id: lesson2.id }, format: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #complete' do
    it 'marks a lesson for a given user as complete' do
      post :complete, params: { course_id: course.to_param, lesson_id: lesson2.to_param }, format: :json
      progress = user.course_progresses.find_by(course_id: course.id)
      expect(progress.completed_lessons.count).to eq(1)
      expect(JSON.parse(response.body)['redirect_path']).to eq(course_lesson_lesson_complete_path(course, lesson2))
    end

    it 'marks a course as complete if the assessment was completed' do
      lesson3.is_assessment = true
      lesson3.save
      post :complete, params: { course_id: course.to_param, lesson_id: lesson3.to_param }, format: :json
      progress = user.course_progresses.find_by(course_id: course.id)
      expect(progress.complete?).to be true
    end

    it 'renders the course completion view if the assessment was completed' do
      lesson3.is_assessment = true
      lesson3.save
      post :complete, params: { course_id: course.to_param, lesson_id: lesson3.to_param }, format: :json
      expect(JSON.parse(response.body)['redirect_path']).to eq(course_completion_path(course.to_param))
    end

    it 'succeeds without a logged in user' do
      sign_out user
      post :complete, params: { course_id: course.to_param, lesson_id: lesson2.to_param }, format: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #lesson_complete' do
    before do
      get :lesson_complete, params: { course_id: course, lesson_id: lesson2 }
    end

    it 'should be a successful response' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns current lesson' do
      expect(assigns(:current_lesson)).to eq(lesson2)
    end

    it 'assigns next lesson' do
      expect(assigns(:next_lesson)).to eq(lesson3)
    end
  end
end
