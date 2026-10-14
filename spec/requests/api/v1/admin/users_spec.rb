# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Users', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin, organization: organization) }

  before do
    host! "#{organization.subdomain}.test.host"
    sign_in admin
  end

  def json
    JSON.parse(response.body)
  end

  context 'when the organization has phone number users enabled' do
    let(:organization) { create(:organization, phone_number_users_enabled: true) }
    let!(:phone_user) { create(:phone_number_user, organization: organization, phone_number: '5551234567') }

    it 'includes phone-number-only users with their phone number' do
      get '/api/v1/admin/users'

      row = json['users'].find { |u| u['id'] == phone_user.id }
      expect(row).to include('email' => nil, 'phoneNumber' => '5551234567')
    end

    it 'searches by phone number, ignoring formatting' do
      create(:phone_number_user, organization: organization, phone_number: '9998887777')

      get '/api/v1/admin/users', params: { q: '(555) 123-' }

      expect(json['users'].map { |u| u['id'] }).to eq([phone_user.id])
    end

    it 'includes a phone number column in the export' do
      get '/api/v1/admin/users/export'

      rows = CSV.parse(response.body)
      expect(rows.first).to include('Phone Number')
      expect(rows.flatten).to include('5551234567')
    end

    describe 'updating roles' do
      %w[trainer admin].each do |role|
        it "requires an email before assigning the #{role} role" do
          patch "/api/v1/admin/users/#{phone_user.id}/update_role", params: { role: role }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json['errors']).to eq(["An email address is required before assigning the #{role} role."])
          expect(phone_user.reload.trainer?).to be false
          expect(phone_user.admin?).to be false
          expect(phone_user.has_role?(:user, organization)).to be true
        end
      end

      it 'promotes a phone number user with an email to trainer' do
        phone_user.update!(email: 'promoted@example.com')

        patch "/api/v1/admin/users/#{phone_user.id}/update_role", params: { role: 'trainer' }

        expect(response).to have_http_status(:ok)
        expect(json['role']).to eq('trainer')
        expect(phone_user.reload.trainer?).to be true
      end

      it 'rolls back the role change when the user fails validation' do
        trainer = create(:user, :trainer, organization: organization)

        # Demoting an email-only trainer makes them a phone number user without a phone number
        patch "/api/v1/admin/users/#{trainer.id}/update_role", params: { role: 'user' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(trainer.reload.trainer?).to be true
      end
    end
  end

  context 'when the organization does not have phone number users enabled' do
    let(:organization) { create(:organization) }
    let!(:user) { create(:user, organization: organization, phone_number: '5551234567') }

    it 'does not expose phone numbers' do
      get '/api/v1/admin/users'

      expect(json['users'].map { |u| u['phoneNumber'] }.uniq).to eq([nil])
    end

    it 'does not match on phone number when searching' do
      get '/api/v1/admin/users', params: { q: '5551234567' }

      expect(json['users']).to be_empty
    end

    it 'omits the phone number column from the export' do
      get '/api/v1/admin/users/export'

      expect(CSV.parse(response.body).first).not_to include('Phone Number')
    end
  end
end
