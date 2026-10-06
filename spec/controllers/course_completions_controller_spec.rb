# frozen_string_literal: true

require 'rails_helper'

describe CourseCompletionsController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:course1) { FactoryBot.create(:course, organization: organization) }
  let(:course2) { FactoryBot.create(:course, organization: organization) }
  let(:course3) { FactoryBot.create(:course, organization: organization) }

  before(:each) do
    request.host = "#{organization.subdomain}.example.com"
  end

  describe 'GET #index' do
    context 'when logged in' do
      let!(:course_progress1) { FactoryBot.create(:course_progress, course: course1, tracked: true, completed_at: Time.zone.now) }
      let!(:course_progress2) { FactoryBot.create(:course_progress, course: course2, tracked: true) }
      let!(:course_progress3) { FactoryBot.create(:course_progress, course: course3, tracked: true, completed_at: Time.zone.now) }

      before(:each) do
        user.course_progresses << [course_progress1, course_progress2, course_progress3]
        sign_in user
      end

      it 'allows the user to view their completed courses' do
        get :index
        expect(assigns(:courses)).to include(course1, course3)
      end
    end

    context 'when logged out' do
      it 'should redirect to login page' do
        get :index
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  describe 'GET #show' do
    context 'when logged in' do
      before(:each) do
        sign_in user
      end

      it 'allows the user to view the complete view' do
        get :show, params: { course_id: course1 }
        expect(assigns(:course)).to eq(course1)
      end

      context 'when the course progress has a completed_at' do
        let!(:course_progress) do
          FactoryBot.create(:course_progress, user: user, course: course1, completed_at: Time.zone.now)
        end

        it 'generates a PDF when sent as format pdf' do
          # the send on this opens a term window on run
          get :show, params: { course_id: course1, format: 'pdf' }
          expect(response).to have_http_status(:success)
          expect(assigns(:pdf)).not_to be_empty
        end
      end

      context 'when every lesson is complete but none of them is the assessment lesson' do
        let(:course) { FactoryBot.create(:course_with_lessons, organization: organization) }
        let!(:course_progress) { FactoryBot.create(:course_progress, user: user, course: course) }

        before(:each) do
          course.lessons.each do |lesson|
            FactoryBot.create(:lesson_completion, course_progress: course_progress, lesson: lesson)
          end
        end

        it 'still generates a certificate PDF instead of erroring' do
          get :show, params: { course_id: course, format: 'pdf' }
          expect(response).to have_http_status(:success)
          expect(assigns(:pdf)).not_to be_empty
        end
      end

      context 'with a historical row from before completion required every lesson' do
        # Simulates a CourseProgress saved back when only the assessment lesson
        # set completed_at: every lesson is done, but completed_at is still nil.
        let(:course) { FactoryBot.create(:course_with_lessons, organization: organization) }
        let!(:course_progress) { FactoryBot.create(:course_progress, user: user, course: course) }

        before(:each) do
          course.lessons.each do |lesson|
            FactoryBot.create(:lesson_completion, course_progress: course_progress, lesson: lesson)
          end
          course_progress.update_columns(completed_at: nil)
        end

        it 'falls back to the lesson completions and still generates a certificate' do
          get :show, params: { course_id: course, format: 'pdf' }
          expect(response).to have_http_status(:success)
          expect(assigns(:pdf)).not_to be_empty
        end
      end

      context 'when the user has no progress at all on the course' do
        it 'returns forbidden instead of erroring' do
          get :show, params: { course_id: course1, format: 'pdf' }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when logged out' do
      it 'should allow completion' do
        get :show, params: { course_id: course1 }
        expect(response).to have_http_status(:success)
        expect(assigns(:course)).to eq(course1)
      end

      context 'when every lesson was completed in session' do
        let(:course) { FactoryBot.create(:course_with_lessons, organization: organization) }

        it 'generates a certificate PDF' do
          session[:completed_lessons] = course.lessons.pluck(:id)

          get :show, params: { course_id: course, format: 'pdf' }
          expect(response).to have_http_status(:success)
          expect(assigns(:pdf)).not_to be_empty
        end
      end

      context 'when nothing was completed in session' do
        it 'returns forbidden instead of generating a certificate' do
          get :show, params: { course_id: course1, format: 'pdf' }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
