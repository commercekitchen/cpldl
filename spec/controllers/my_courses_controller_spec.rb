# frozen_string_literal: true

require 'rails_helper'

describe MyCoursesController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:category) { FactoryBot.create(:category, organization: organization) }
  let(:disabled_category) { FactoryBot.create(:category, :disabled, organization: organization) }
  let(:course1) { FactoryBot.create(:course, title: 'Course 1', language: @english, category: category, organization: organization) }
  let(:course2) { FactoryBot.create(:course, title: 'Course 2', language: @english, organization: organization) }
  let(:course3) { FactoryBot.create(:course, title: 'Course 3', language: @english, organization: organization) }
  let(:course4) { FactoryBot.create(:course, title: 'Course 4', language: @english, category: disabled_category, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  context 'authenticated user' do

    before(:each) do
      request.host = "#{organization.subdomain}.example.com"
      sign_in user
    end

    describe 'GET #index' do
      let!(:course_progress1) { FactoryBot.create(:course_progress, user: user, course_id: course1.id, tracked: true) }
      let!(:course_progress2) { FactoryBot.create(:course_progress, user: user, course_id: course2.id, tracked: false) }
      let!(:course_progress3) { FactoryBot.create(:course_progress, user: user, course_id: course3.id, tracked: true) }
      let!(:course_progress4) { FactoryBot.create(:course_progress, user: user, course_id: course4.id, tracked: true) }

      before(:each) do
        user.course_progresses << [course_progress1, course_progress2, course_progress3]
      end

      it 'allows the user to view their tracked courses' do
        get :index
        expect(assigns(:courses)).to include(course1, course3, course4)
      end

      it 'assigns @results if search params exist' do
        course1.update(description: 'Mocha Java Scripta')
        get :index, params: { search: 'java' }
        expect(assigns(:results)).to eq([course1])
      end

      it 'assigns search results to @courses' do
        course1.update(description: 'Mocha Java Scripta')
        get :index, params: { search: 'java' }
        expect(assigns(:courses)).to eq([course1])
      end
    end
  end

  context 'non-authenticated user' do

    before(:each) do
      request.host = "#{organization.subdomain}.example.com"
    end

    describe 'GET #index' do
      it 'should redirect to login page' do
        get :index
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'POST #create' do
      it 'should redirect to login page' do
        get :index
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end

  end

end
