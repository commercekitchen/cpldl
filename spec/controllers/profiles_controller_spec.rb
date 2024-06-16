# frozen_string_literal: true

require 'rails_helper'

describe ProfilesController do

  before(:each) do
    create(:default_organization)
    @request.host = 'www.test.host'
  end

  describe '#show' do
    context 'when logged in' do
      it "should show the user's profile information" do
        user = create(:user)
        sign_in user
        get :show
        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged out' do
      it 'should redirect any action to login page' do
        get :show
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  describe '#update' do
    context 'when logged in' do
      before(:each) do
        @user = create(:user)
        sign_in @user
      end

      it 'allows the user to update their profile information' do
        profile_params = { first_name: 'Robby', zip_code: '12345',
                           language: @english, opt_out_of_recommendations: true }
        put :update, params: { id: @user.profile, profile: profile_params, authenticity_token: set_authenticity_token }
        @user.reload
        expect(@user.first_name).to eq('Robby')
        expect(@user.profile.zip_code).to eq('12345')
        expect(@user.profile.language.name).to eq('English')
        expect(@user.profile.opt_out_of_recommendations).to be true
      end
    end

    context 'when logged out' do
      it 'should redirect any action to login page' do
        put :update
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end
end
