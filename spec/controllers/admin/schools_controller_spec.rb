# frozen_string_literal: true

require 'rails_helper'

describe Admin::SchoolsController do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:organization) { admin.organization }
  let(:other_subsite_admin) { FactoryBot.create(:user, :admin) }
  let!(:enabled_school) { FactoryBot.create(:school, organization: organization) }
  let!(:disabled_school) { FactoryBot.create(:school, :disabled, organization: organization) }

  before(:each) do
    @request.host = "#{organization.subdomain}.test.host"
    sign_in admin
  end

  describe 'GET #index' do
    it 'assigns schools for organization' do
      get :index
      expect(assigns(:schools)).to contain_exactly(enabled_school, disabled_school)
    end

    it 'creates new empty school' do
      get :index
      expect(assigns(:new_school)).to be_a_new(School)
    end
  end

  describe 'POST #create' do
    it 'should create new school with valid attributes' do
      valid_attributes = {
        school_name: 'Lincoln Elementary',
        school_type: 'elementary'
      }

      expect do
        post :create, params: { school: valid_attributes, format: 'js' }
      end.to change { organization.schools.elementary.count }.by(1)
    end

    it 'should not create a school for another subsite' do
      sign_out admin
      sign_in other_subsite_admin

      expect do
        post :create, params: { school: { school_name: 'Some School' }, format: 'js' }
      end.to_not change(School, :count)
    end
  end

  describe 'PATCH #update' do
    let(:school) { create(:school, organization: organization, school_type: 'elementary') }

    it 'updates school' do
      expect do
        patch :update, params: { id: school.id, school: { school_type: 'middle_school' }, format: 'js' }
      end.to change { school.reload.school_type }.from('elementary').to('middle_school')
    end

    it 'does not update school for another subsite' do
      sign_out admin
      sign_in other_subsite_admin

      expect do
        patch :update, params: { id: school.id, school: { school_type: 'middle_school' }, format: 'js' }
      end.to_not change { school.reload.school_type }
    end
  end

  describe 'POST #toggle' do
    it 'should disable enabled school' do
      expect(enabled_school.enabled).to be true
      post :toggle, params: { school_id: enabled_school, format: 'js' }
      enabled_school.reload
      expect(enabled_school.enabled).to be false
    end

    it 'should enable disabled school' do
      expect(disabled_school.enabled).to be false
      post :toggle, params: { school_id: disabled_school, format: 'js' }
      disabled_school.reload
      expect(disabled_school.enabled).to be true
    end
  end

end
