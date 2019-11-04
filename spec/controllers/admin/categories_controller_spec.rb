# frozen_string_literal: true

require 'rails_helper'

describe Admin::CategoriesController do

  before(:each) do
    @www = create(:default_organization)
    @dpl = create(:organization, subdomain: 'dpl')

    @www_admin = create(:user, :admin, organization: @www)
    @dpl_admin = create(:user, :admin, organization: @dpl)

    @www_category1 = create(:category, organization: @www)
    @www_category2 = create(:category, organization: @www)
    @www_category3 = create(:category, :disabled, organization: @www)

    @dpl_category1 = create(:category, organization: @dpl)
    @dpl_category2 = create(:category, organization: @dpl)
    @dpl_category3 = create(:category, :disabled, organization: @dpl)
  end

  context 'www admin' do
    before(:each) do
      @request.host = 'www.test.host'
      sign_in @www_admin
    end

    describe 'GET #index' do
      before(:each) do
        get :index
      end

      it 'should assign existing dpl_categories' do
        expect(assigns(:categories)).to include(@www_category1, @www_category2, @www_category3)
      end

      it 'should only assign dpl categories' do
        expect(assigns(:categories).count).to eq(3)
      end
    end

    describe 'POST #create' do
      it 'should create category from new name' do
        expect do
          post :create, params: { category: { name: "#{@www_category1.name}_#{Faker::Lorem.word}" } }, format: 'js'
        end.to change(Category, :count).by(1)
      end

      it 'should not create category with repeat name' do
        expect do
          post :create, params: { category: { name: @www_category1.name } }, format: 'js'
        end.not_to change(Category, :count)
      end
    end

    describe 'POST #toggle' do
      it 'should disable enabled category' do
        expect(@www_category1.enabled).to be true
        post :toggle, params: { category_id: @www_category1 }, format: 'js'

        @www_category1.reload
        expect(@www_category1.enabled).to be false
      end

      it 'should disable enabled category' do
        expect(@www_category3.enabled).to be false
        post :toggle, params: { category_id: @www_category3.id }, format: 'js'
        @www_category3.reload
        expect(@www_category3.enabled).to be true
      end
    end
  end

  context 'subdomain admin' do
    before(:each) do
      @request.host = 'dpl.test.host'
      sign_in @dpl_admin
    end

    describe 'GET #index' do
      before(:each) do
        get :index
      end

      it 'should assign existing dpl_categories' do
        expect(assigns(:categories)).to include(@dpl_category1, @dpl_category2, @dpl_category3)
      end

      it 'should only assign dpl categories' do
        expect(assigns(:categories).count).to eq(3)
      end
    end

    describe 'POST #create' do
      it 'should create category from new name' do
        expect do
          post :create, params: { category: { name: "#{@dpl_category1.name}_#{Faker::Lorem.word}" } }, format: 'js'
        end.to change(Category, :count).by(1)
      end

      it 'should not create category with repeat name' do
        expect do
          post :create, params: { category: { name: @dpl_category1.name } }, format: 'js'
        end.not_to change(Category, :count)
      end
    end

    describe 'POST #toggle' do
      it 'should disable enabled category' do
        expect(@dpl_category1.enabled).to be true
        post :toggle, params: { category_id: @dpl_category1 }, format: 'js'
        @dpl_category1.reload
        expect(@dpl_category1.enabled).to be false
      end

      it 'should disable enabled category' do
        expect(@dpl_category3.enabled).to be false
        post :toggle, params: { category_id: @dpl_category3 }, format: 'js'
        @dpl_category3.reload
        expect(@dpl_category3.enabled).to be true
      end
    end
  end
end
