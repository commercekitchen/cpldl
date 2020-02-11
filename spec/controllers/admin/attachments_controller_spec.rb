# frozen_string_literal: true

require 'rails_helper'

describe Admin::AttachmentsController do
  let(:organization) { FactoryBot.create(:default_organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:course) { FactoryBot.create(:course, organization: organization) }
  let!(:attachment) { FactoryBot.create(:attachment, course: course) }

  before(:each) do
    @request.host = 'www.test.host'
    sign_in admin
    @request.env['HTTP_REFERER'] = 'http://test.com/admin/courses/new'
  end

  describe 'DELETE #destroy' do
    context 'success' do
      it 'deletes and attachment' do
        expect { delete :destroy, params: { id: attachment.to_param } }.to change(Attachment, :count).by(-1)
      end
    end
  end
end
