# frozen_string_literal: true

require 'rails_helper'

describe Admin::LibraryLocationsController do
  let(:org) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: org) }

  before do
    @request.host = "#{org.subdomain}.test.host"
    sign_in admin
  end

  describe 'GET #index' do
    let!(:branch1) { FactoryBot.create(:library_location, organization: org) }
    let!(:branch2) { FactoryBot.create(:library_location, organization: org) }

    before do
      get :index
    end

    it 'should return an ok status' do
      expect(response).to have_http_status(:ok)
    end

    it 'should assign branches as @library_locations' do
      expect(assigns(:library_locations)).to include(branch1, branch2)
    end
  end

  describe 'GET #new' do
    before do
      get :new
    end

    it 'should build a library_location' do
      expect(assigns(:library_location)).to be_a_new(LibraryLocation)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) { { name: 'New Location', zipcode: '12345' } }
    let(:invalid_attributes) { { name: 'No Zipcode Location' } }

    context 'with valid params' do
      it 'should create a library location from valid attributes' do
        expect do
          post :create, params: { library_location: valid_attributes }
        end.to change(LibraryLocation, :count).by(1)
      end

      it 'should assign correct success message' do
        post :create, params: { library_location: valid_attributes }
        expect(flash[:notice]).to eq('Library Branch was successfully created.')
      end

      it 'should redirect to library locations index' do
        post :create, params: { library_location: valid_attributes }
        expect(response).to redirect_to(admin_library_locations_path)
      end
    end

    context 'invalid params' do
      it 'should not create a library location from invalid attributes' do
        expect do
          post :create, params: { library_location: invalid_attributes }
        end.to_not change(LibraryLocation, :count)
      end

      it 'should re-render new' do
        post :create, params: { library_location: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    let(:branch) { FactoryBot.create(:library_location, organization: org) }

    it 'should find branch' do
      get :edit, params: { id: branch.id }
      expect(assigns(:library_location)).to eq(branch)
    end
  end

  describe 'PATCH #update' do
    let(:branch) { FactoryBot.create(:library_location, name: 'Branch', zipcode: '12345', organization: org) }

    it 'should redirect to library locations index' do
      patch :update, params: { id: branch.id, library_location: { name: 'New Branch Name' } }
      expect(response).to redirect_to(admin_library_locations_path)
    end

    it 'should assign correct success message' do
      patch :update, params: { id: branch.id, library_location: { name: 'New Branch Name' } }
      expect(flash[:notice]).to eq('Library Branch was successfully updated.')
    end

    it 'should change branch name' do
      patch :update, params: { id: branch.id, library_location: { name: 'New Branch Name' } }
      expect(branch.reload.name).to eq('New Branch Name')
    end

    it 'should change branch zipcode' do
      patch :update, params: { id: branch.id, library_location: { zipcode: '54321' } }
      expect(branch.reload.zipcode).to eq(54_321)
    end

    it 'should render edit with invalid params' do
      patch :update, params: { id: branch.id, library_location: { name: nil } }
      expect(response).to render_template(:edit)
    end
  end

  describe 'DELETE #destroy' do
    let!(:branch) { FactoryBot.create(:library_location, organization: org) }

    it 'should remove a LibraryLocation' do
      expect do
        delete :destroy, params: { id: branch.id }
      end.to change(LibraryLocation, :count).by(-1)
    end

    it 'should redirect to index' do
      delete :destroy, params: { id: branch.id }
      expect(response).to redirect_to(admin_library_locations_path)
    end

    it 'should include successful delete message' do
      delete :destroy, params: { id: branch.id }
      expect(flash[:notice]).to eq('Library Branch was successfully deleted.')
    end

    it 'should redirect to index on failed destroy' do
      expect_any_instance_of(LibraryLocation).to receive(:destroy).and_return(false)
      delete :destroy, params: { id: branch.id }
      expect(response).to redirect_to(admin_library_locations_path)
    end

    it 'should include correct message on failed delete' do
      expect_any_instance_of(LibraryLocation).to receive(:destroy).and_return(false)
      delete :destroy, params: { id: branch.id }
      expect(flash[:alert]).to eq('Sorry, we were unable to remove this library branch.')
    end
  end

  describe 'POST #sort' do
    let(:library_location_1) { FactoryBot.create(:library_location, organization: org, sort_order: 1) }
    let(:library_location_2) { FactoryBot.create(:library_location, organization: org, sort_order: 2) }

    it 'should change course order' do
      order_params = { '0' => { id: library_location_2.id, position: 1 }, '1' => { id: library_location_1.id, position: 2 } }
      post :sort, params: { order: order_params }

      expect(library_location_1.reload.sort_order).to eq(2)
      expect(library_location_2.reload.sort_order).to eq(1)
    end
  end
end
