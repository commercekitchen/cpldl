# frozen_string_literal: true

require 'rails_helper'

describe RegistrationsController do
  let(:email) { 'test@example.com' }
  let(:password) { 'password' }
  let(:profile_attributes) do
    { first_name: 'First', last_name: 'Last' }
  end

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'no program registration' do
    let(:organization) { FactoryBot.create(:organization) }

    before do
      @request.host = "#{organization.subdomain}.test.host"
    end

    describe '#create' do
      let(:user_params) do
        { email: email, password: password, password_confirmation: password, profile_attributes: profile_attributes }
      end

      it 'should create a new user' do
        expect do
          post :create, params: { user: user_params }
        end.to change(User, :count).by(1)
      end

      it 'should redirect to profile path' do
        post :create, params: { user: user_params }
        expect(response).to redirect_to(profile_path)
      end
    end
  end

  describe 'program registration' do
    let(:program_location) { FactoryBot.create(:program_location) }
    let(:program) { program_location.program }
    let(:organization) { program.organization }

    before do
      @request.host = "#{organization.subdomain}.test.host"
    end

    describe '#create' do
      it 'should attach program if selected' do
        user_params = { email: email, password: password, password_confirmation: password,
                        profile_attributes: profile_attributes, program_type: program.parent_type,
                        program_id: program.id, program_location_id: program_location.id }
        post :create, params: { user: user_params }
        expect(assigns(:user).program_id).to eq(program.id)
        expect(assigns(:user).program_location_id).to eq(program_location.id)
      end
    end
  end

  describe 'partner registration' do
    let(:partner) { FactoryBot.create(:partner) }
    let(:organization) { partner.organization }

    before do
      @request.host = "#{organization.subdomain}.test.host"
    end

    describe '#create' do
      it 'should attach partner if selected' do
        user_params = { email: email, password: password, password_confirmation: password,
                        profile_attributes: profile_attributes, partner_id: partner.id }
        post :create, params: { user: user_params }
        expect(assigns(:user).partner_id).to eq(partner.id)
      end
    end
  end
end
