# frozen_string_literal: true

require 'rails_helper'

describe CourseProgressesController do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:course1) { FactoryBot.create(:course, title: 'Course 1', language: @english, organization: organization) }
  let(:course2) { FactoryBot.create(:course, title: 'Course 2', language: @english, organization: organization) }
  let(:lesson1) { create(:lesson, lesson_order: 1, course: course1) }
  let(:lesson2) { create(:lesson, lesson_order: 2, course: course1) }
  let(:lesson3) { create(:lesson, lesson_order: 3, course: course1) }
  let(:lesson4) { create(:lesson, course: course2) }

  before(:each) do
    request.host = "#{organization.subdomain}.example.com"
  end

  context 'authenticated user' do

    before(:each) do
      sign_in user
    end

    describe 'PUT #update' do
      it 'creates a new course progress if none exists' do
        expect do
          put :update, params: { course_id: course1.id, tracked: 'true' }
        end.to change(CourseProgress, :count).by(1)
      end

      it 'marks an existing course progress as tracked' do
        progress = CourseProgress.create(user: user, course: course1, tracked: false)

        put :update, params: { course_id: course1.id, tracked: 'true' }
        expect(progress.reload.tracked).to be true
      end

      it 'marks an existing course as not tracked' do
        progress = CourseProgress.create(user: user, course: course1, tracked: true)

        put :update, params: { course_id: course1.id, tracked: 'false' }
        expect(progress.reload.tracked).to be false
      end
    end
  end

  context 'non-authenticated user' do
    describe 'PUT #update' do
      it 'should redirect to the login page' do
        put :update, params: { course_id: course1.id, tracked: 'true' }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

end
