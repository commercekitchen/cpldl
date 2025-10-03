# frozen_string_literal: true

require 'rails_helper'

describe Trainer::BaseController do
  describe '#authorize_trainer' do
    let(:organization) { create(:chicago) }
    let(:user) { create(:user, organization: organization) }

    before(:each) do
      user.add_role(:trainer, organization)
      @request.host = 'chipublib.test.host'
      sign_in user
    end
    it 'authorizes a trainer' do
      controller.authorize_trainer
      expect(response).to have_http_status(:success)
    end
  end
end
