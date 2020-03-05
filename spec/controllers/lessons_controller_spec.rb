# frozen_string_literal: true

require 'rails_helper'

describe LessonsController do
  let(:org) { FactoryBot.create(:organization, login_required: false) }
  let(:user) { FactoryBot.create(:user, organization: org) }
  let(:course) { FactoryBot.create(:course, organization: org) }
  let!(:lesson1) { FactoryBot.create(:lesson, lesson_order: 1, course: course) }
  let!(:lesson2) { FactoryBot.create(:lesson, lesson_order: 2, course: course) }
  let!(:lesson3) { FactoryBot.create(:lesson, lesson_order: 3, course: course) }
  let!(:draft_lesson) { FactoryBot.create(:lesson, course: course, pub_status: 'D') }
  let!(:archived_lesson) { FactoryBot.create(:lesson, course: course, pub_status: 'A') }

  before(:each) do
    @request.host = "#{org.subdomain}.test.host"
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

    it 'sets correct flash for draft lessons' do
      get :show, params: { course_id: course.to_param, id: draft_lesson.id }, format: :json
      expect(flash[:notice]).to eq('That lesson is not available at this time.')
    end

    it 'redirects to root for archived lessons' do
      get :show, params: { course_id: course.to_param, id: draft_lesson.id }, format: :json
      expect(response).to redirect_to(root_path)
    end

    it 'sets correct flash for archived lessons' do
      get :show, params: { course_id: course.to_param, id: archived_lesson.id }, format: :json
      expect(flash[:notice]).to eq('That lesson is no longer available.')
    end

    it 'redirects to root for archived lessons' do
      get :show, params: { course_id: course.to_param, id: archived_lesson.id }, format: :json
      expect(response).to redirect_to(root_path)
    end

    context 'preview' do
      let(:pla) { FactoryBot.create(:default_organization) }
      let(:pla_course) { FactoryBot.create(:course_with_lessons, organization: pla) }
      let(:pla_lesson) { pla_course.lessons.first }
      let(:subsite_admin) { FactoryBot.create(:user, :admin, organization: org) }

      it 'authorizes course preview' do
        expect(@controller).to receive(:authorize).with(pla_course, :preview?)
        allow(@controller).to receive(:verify_authorized)
        get :show, params: { course_id: pla_course.to_param, id: pla_lesson.to_param, preview: true }
      end

      it 'should respond with 200 if accessed by subsite admin' do
        sign_out user
        sign_in subsite_admin
        get :show, params: { course_id: pla_course.to_param, id: pla_lesson.to_param, preview: true }
        expect(response).to have_http_status :ok
      end
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

    it 'does not create a duplicate lesson completion' do
      course_progress = FactoryBot.create(:course_progress, course: course, user: user)
      FactoryBot.create(:lesson_completion, lesson: lesson1, course_progress: course_progress)

      expect do
        post :complete, params: { course_id: course.to_param, lesson_id: lesson1.to_param }, format: :json
      end.to_not change(LessonCompletion, :count)
    end

    context 'preview' do
      let(:pla) { FactoryBot.create(:default_organization) }
      let(:pla_course) { FactoryBot.create(:course_with_lessons, organization: pla) }
      let(:pla_lesson) { pla_course.lessons.first }
      let(:subsite_admin) { FactoryBot.create(:user, :admin, organization: org) }

      before do
        sign_out user
        sign_in subsite_admin
      end

      it 'authorizes course preview' do
        expect(@controller).to receive(:authorize).with(pla_course, :preview?)
        allow(@controller).to receive(:verify_authorized)
        post :complete, params: { course_id: pla_course.to_param, lesson_id: pla_lesson.to_param, preview: true }, format: :json
      end

      it 'includes preview parameter if a preview lesson is finished' do
        post :complete, params: { course_id: pla_course.to_param, lesson_id: pla_lesson.to_param, preview: true }, format: :json
        expect(JSON.parse(response.body)['redirect_path']).to eq(course_lesson_lesson_complete_path(pla_course, pla_lesson, preview: true))
      end

      it 'returns to course preview if finishing a preview course' do
        pla_assessment = pla_course.lessons.last
        pla_assessment.update(is_assessment: true)
        post :complete, params: { course_id: pla_course.to_param, lesson_id: pla_assessment.to_param, preview: true }, format: :json
        expect(JSON.parse(response.body)['redirect_path']).to eq(admin_course_preview_path(pla_course.to_param))
      end
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
