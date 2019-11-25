# frozen_string_literal: true

require 'rails_helper'

describe Admin::UsersController do
  let(:org) { create(:default_organization) }
  let(:admin) { create(:user, :admin, organization: org) }
  let(:trainer) { create(:user, :trainer, organization: org) }

  before do
    @request.host = "#{org.subdomain}.test.host"
    sign_in admin
  end

  describe 'GET #index' do
    let!(:user1) { create(:user, email: 'one@example.com', organization: org) }
    let!(:user2) { create(:user, email: 'two@example.com', organization: org) }
    let!(:user3) { create(:user, email: 'three@example.com', organization: org) }

    it 'assigns all users as @users' do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:users)).to include(user1, user2, user3)
      expect(assigns(:users).count).to eq(4)
    end

    it 'assigns all users as @users with an empty params' do
      get :index, params: {}
      expect(assigns(:users)).to include(user1, user2, user3)
    end

    it 'assigns search results to @users' do
      get :index, params: { users_search: 'two' }
      expect(assigns(:users)).to eq([user2])
    end

    it 'allows trainer to view users index' do
      sign_in trainer
      get :index
      expect(assigns(:users)).to include(user1, user2, user3)
    end
  end

  describe 'PATCH #change_user_roles' do
    let(:user) { create(:user, organization: org) }

    it 'updates the role' do
      patch :change_user_roles, params: { id: user.id.to_param, value: 'Trainer' }
      expect(user.reload.current_roles).to eq('trainer')

      patch :change_user_roles, params: { id: user.id.to_param, value: 'Admin' }
      expect(user.reload.current_roles).to eq('admin')
    end
  end

  describe '#export_user_info' do
    before do
      4.times do
        create(:user, organization: org)
      end

      get :export_user_info, format: :csv
    end

    it 'assigns correct number of users' do
      expect(assigns(:users).count).to eq(5)
    end
  end
end
