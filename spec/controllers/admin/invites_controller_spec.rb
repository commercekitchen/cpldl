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
end
