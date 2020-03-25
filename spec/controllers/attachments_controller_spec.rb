# frozen_string_literal: true

require 'rails_helper'

describe AttachmentsController do
  let(:pla) { FactoryBot.create(:default_organization) }
  let(:pla_course) { FactoryBot.create(:course, organization: pla) }
  let(:subsite_course) { FactoryBot.create(:course, parent: pla_course) }
  let(:subsite) { subsite_course.organization }
  let(:subsite_user) { FactoryBot.create(:user, organization: subsite) }
  let(:other_subsite_user) { FactoryBot.create(:user) }

  let(:document) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf') }
  let(:attachment) { FactoryBot.create(:attachment, document: document, course: pla_course) }

  describe '#show' do
    context 'visitor on subsite' do
      before do
        request.host = "#{subsite.subdomain}.example.com"
      end

      it 'allows the visitor to view an attachment' do
        get :show, params: { id: attachment.id }
        expect(response).to have_http_status(:success)
      end

      it 'does not allow visitor to view attachment if course is private' do
        subsite_course.update!(access_level: 'authenticated_users')
        get :show, params: { id: attachment.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'user on subsite' do
      before do
        request.host = "#{subsite.subdomain}.example.com"
        sign_in subsite_user
      end

      it 'allows the user to view an attachment' do
        get :show, params: { id: attachment.id }
        expect(response).to have_http_status(:success)
      end

      it 'allows user to view attachment if course is private' do
        subsite_course.update!(access_level: 'authenticated_users')
        get :show, params: { id: attachment.id }
        expect(response).to have_http_status(:success)
      end
    end

    context 'user on another subsite' do
      before do
        request.host = "#{other_subsite_user.organization.subdomain}.example.com"
        sign_in other_subsite_user
      end

      it 'does not allow user to view attachment' do
        get :show, params: { id: attachment.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
