# frozen_string_literal: true

require 'rails_helper'

describe QuizResponsesController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  before(:each) do
    request.host = "#{organization.subdomain}.example.com"
  end

  describe 'GET #new' do
    context 'when logged in' do

      before(:each) do
        sign_in user
      end

      it 'should have a valid route and template' do
        get :new
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end

    end

    context 'when not logged in' do

      it 'should redirect to sign in path' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'should alert user they must be signed in' do
        get :new
        expect(flash[:alert]).to eq('You need to sign in or sign up before continuing.')
      end

    end
  end

  describe 'POST #create' do
    let(:choices) do
      { 'set_one' => '2', 'set_two' => '2', 'set_three' => '3' }
    end

    let(:core_topic) { FactoryBot.create(:topic, title: 'Core') }
    let(:topic) { FactoryBot.create(:topic, title: 'Government') }
    let!(:desktop_course) { create(:course, format: 'D', level: 'Intermediate', topics: [core_topic], organization: organization) }
    let!(:mobile_course) { create(:course, format: 'M', level: 'Intermediate', topics: [core_topic], organization: organization) }
    let!(:topic_course) { create(:course, topics: [topic], organization: organization) }

    context 'when logged in' do

      before(:each) do
        sign_in user
      end

      it 'should add correct number of course progresses to user' do
        expect do
          post :create, params: choices
        end.to change(CourseProgress, :count).by(3)
      end

      it 'should add correct course progresses to user' do
        post :create, params: choices
        expect(user.reload.course_progresses.map(&:course_id)).to include(desktop_course.id, mobile_course.id, topic_course.id)
      end

      it 'should store quiz responses for user' do
        post :create, params: choices
        expect(user.reload.quiz_responses_object).to eq(choices)
      end

      it 'should not overwrite quiz responses for user' do
        post :create, params: choices
        post :create, params: { 'set_one' => '3', 'set_two' => '3', 'set_three' => '5' }
        expect(user.reload.quiz_responses_object).to eq(choices)
      end
    end

    context 'when not logged in' do
    end
  end

end
