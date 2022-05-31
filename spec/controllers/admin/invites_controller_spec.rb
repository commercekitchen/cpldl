# frozen_string_literal: true

require 'rails_helper'

describe Admin::InvitesController do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:organization) { admin.organization }
  let(:user) { FactoryBot.create(:user, organization: organization) }

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @request.host = "#{organization.subdomain}.test.host"
    sign_in admin
  end

  describe '#create' do
    context 'existing user' do
      before do
        post :create, params: { user: { email: user.email } }
      end

      it 'should assign correct flash' do
        expect(flash[:alert]).to eq('The user already exists')
      end

      it 'should redirect to new invitation path' do
        expect(response).to redirect_to(new_user_invitation_path)
      end
    end

    context 'new user' do
      it 'should create a new user' do
        expect do
          post :create, params: { user: { email: 'new_email@example.com' } }
        end.to change(User, :count).by(1)
      end
    end
  end

  describe '#edit' do
    before do
      @invited_user = AdminInvitationService.invite(email: 'test_invite@example.com', organization: organization, inviter: admin)
      @token = @invited_user.raw_invitation_token
      sign_out admin
    end

    it 'should have an ok response' do
      get :edit, params: { invitation_token: @token }
      expect(response).to have_http_status(:ok)
    end

    it 'should not show sidebar' do
      get :edit, params: { invitation_token: @token }
      expect(assigns(:show_sidebar)).to be_falsey
    end
  end

  describe '#update' do
    let(:invited_user) do
      AdminInvitationService.invite(email: 'test_invite@example.com', organization: organization, inviter: admin)
    end
    let(:token) { invited_user.raw_invitation_token }
    let(:send_update_request) do
      put :update, params: { user: { invitation_token: token, password: 'password', password_confirmation: 'password' } }
    end

    before do
      sign_out admin
    end

    it 'should have a found response' do
      send_update_request
      expect(response).to have_http_status(:found)
    end

    it 'should redirect to profile' do
      send_update_request
      expect(response).to redirect_to(profile_path)
    end

    it 'should update password' do
      expect(invited_user.valid_password?('password')).to be_falsey
      send_update_request
      expect(invited_user.reload.valid_password?('password')).to be_truthy
    end
  end
end
