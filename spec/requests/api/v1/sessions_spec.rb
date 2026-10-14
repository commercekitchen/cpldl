# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let(:organization) { create(:organization, phone_number_users_enabled: true) }

  before do
    host! "#{organization.subdomain}.test.host"
  end

  def json
    JSON.parse(response.body)
  end

  context 'phone number sign-in' do
    it 'signs in a phone number user' do
      create(:phone_number_user, organization: organization, phone_number: '5551234567')

      post '/api/v1/session', params: { phone_number: { phone: '(555) 123-4567' } }

      expect(response).to have_http_status(:ok)
    end

    %i[admin trainer].each do |role|
      it "rejects a #{role}" do
        create(:user, role, organization: organization, phone_number: '5551234567')

        post '/api/v1/session', params: { phone_number: { phone: '5551234567' } }

        expect(response).to have_http_status(:forbidden)
        expect(json['message']).to eq("Phone number sign-in is not allowed for #{role} accounts.")
      end
    end
  end

  context 'email and password sign-in' do
    it 'signs in a trainer' do
      trainer = create(:user, :trainer, organization: organization, email: 'trainer@example.com')

      post '/api/v1/session', params: { email: 'trainer@example.com', password: 'abcd1234' }

      expect(response).to have_http_status(:ok)
      expect(json['id']).to eq(trainer.id)
      expect(json['roles']).to eq(['trainer'])
    end
  end
end
