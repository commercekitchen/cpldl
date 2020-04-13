# frozen_string_literal: true

require 'rails_helper'

describe CoursesController do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }

  let(:category) { FactoryBot.create(:category, organization: organization) }
  let(:disabled_category) { FactoryBot.create(:category, :disabled, organization: organization) }

  let!(:course1) do
    FactoryBot.create(:course, title: 'Course 1', organization: organization, category: category)
  end

  let!(:course2) do
    FactoryBot.create(:course, title: 'Course 2', organization: organization)
  end

  let!(:course3) do
    FactoryBot.create(:course, title: 'Course 3', description: 'Ruby on Rails', organization: organization)
  end

  let!(:disabled_category_course) do
    FactoryBot.create(:course, title: 'Disabled Category Course', organization: organization, category: disabled_category)
  end

  before do
    request.host = "#{organization.subdomain}.example.com"
  end

  describe 'GET #index' do
    it 'assigns all courses as @courses' do
      get :index
      expect(assigns(:courses)).to contain_exactly(course1, course2, course3, disabled_category_course)
    end

    it 'assigns all courses as @courses with an empty params' do
      get :index, params: {}
      expect(assigns(:courses)).to contain_exactly(course1, course2, course3, disabled_category_course)
    end

    it 'assigns search results to @courses' do
      get :index, params: { search: 'ruby' }
      expect(assigns(:courses)).to contain_exactly(course3)
    end

    it 'responds to json' do
      get :index, format: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested course (by id) as @course' do
      get :show, params: { id: course2.to_param }
      expect(assigns(:course)).to eq(course2)
    end

    it 'assigns the requested course (by friendly id) as @course' do
      get :show, params: { id: course2.friendly_id }
      expect(assigns(:course)).to eq(course2)
    end

    it 'allows the admin to change the title, and have the old title redirect to the new title' do
      old_url = course1.friendly_id
      course1.title = 'New Title'
      course1.save

      get :show, params: { id: old_url }
      expect(assigns(:course)).to eq(course1)
      expect(response).to have_http_status(:success)

      get :show, params: { id: course1.friendly_id }
      expect(assigns(:course)).to eq(course1)
    end

    it 'responds to json' do
      get :show, params: { id: course1.to_param, format: :json }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #skills' do
    context 'when logged in' do
      before(:each) do
        sign_in user
      end

      it 'allows the user to view skills' do
        get :skills, params: { course_id: course1 }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when not logged in' do
      it 'should allow view' do
        get :skills, params: { course_id: course1 }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when viewing another subsite' do
      let(:other_subsite) { FactoryBot.create(:organization, subdomain: 'foobar') }

      before do
        request.host = "#{other_subsite.subdomain}.example.com"
      end

      it 'should not allow view' do
        get :skills, params: { course_id: course1 }
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end
  end

end
