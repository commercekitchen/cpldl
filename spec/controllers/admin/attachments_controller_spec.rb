# frozen_string_literal: true

require 'rails_helper'

describe Admin::AttachmentsController do

  before(:each) do
    @organization = create(:default_organization)
    @request.host = 'www.test.host'
    @attachment = create(:attachment)
    @admin = create(:user, :admin, organization: @organization)
    sign_in @admin

    @request.env['HTTP_REFERER'] = 'http://test.com/admin/courses/new'
  end

  describe 'DELETE #destroy' do
    context 'success' do
      it 'deletes and attachment' do
        expect { delete :destroy, params: { id: @attachment.to_param } }.to change(Attachment, :count).by(-1)
      end
    end
  end
end
