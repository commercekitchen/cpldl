# frozen_string_literal: true

require 'rails_helper'

describe Admin::CategoriesController do
  let(:org) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, :admin, organization: org) }
  let(:other_subsite_user) { FactoryBot.create(:user, :admin) }
  let!(:category1) { FactoryBot.create(:category, organization: org) }
  let!(:category2) { FactoryBot.create(:category, organization: org, category_order: 2) }
  let!(:category3) { FactoryBot.create(:category, :disabled, organization: org, category_order: 3) }

  context 'authorized users' do
    before(:each) do
      @request.host = "#{org.subdomain}.test.host"
      sign_in user
    end

    describe 'GET #index' do
      before(:each) do
        get :index
      end

      it 'should assign existing dpl_categories' do
        expect(assigns(:categories)).to include(category1, category2, category3)
      end

      it 'should only assign dpl categories' do
        expect(assigns(:categories).count).to eq(3)
      end
    end

    describe 'POST #create' do
      it 'should create category from new name' do
        expect do
          post :create, params: { category: { name: "#{category1.name}_#{Faker::Lorem.word}" } }, format: 'js'
        end.to change(Category, :count).by(1)
      end

      it 'should not create category with repeat name' do
        expect do
          post :create, params: { category: { name: category1.name } }, format: 'js'
        end.not_to change(Category, :count)
      end
    end

    describe 'POST #sort' do
      it 'should change category order' do
        order_params = { '0' => { id: category2.id, position: 1 }, '1' => { id: category1.id, position: 2 } }
        post :sort, params: { order: order_params }
        expect(category1.reload.category_order).to eq(2)
        expect(category2.reload.category_order).to eq(1)
      end
    end

    describe 'POST #toggle' do
      it 'should disable enabled category' do
        expect(category1.enabled).to be true
        post :toggle, params: { category_id: category1 }, format: 'js'
        category1.reload
        expect(category1.enabled).to be false
      end

      it 'should enable disabled category' do
        expect(category3.enabled).to be false
        post :toggle, params: { category_id: category3 }, format: 'js'
        category3.reload
        expect(category3.enabled).to be true
      end
    end
  end

  context 'unauthorized user' do
    before do
      @request.host = "#{org.subdomain}.test.host"
      sign_in other_subsite_user
    end

    describe 'GET #index' do
      it 'should not assign any categories' do
        get :index
        expect(assigns(:categories)).to be_empty
      end
    end

    describe 'POST #create' do
      it 'should not create category for incorrect subsite' do
        expect do
          post :create, params: { category: { name: "#{category1.name}_#{Faker::Lorem.word}" } }, format: 'js'
        end.to_not change(Category, :count)
      end
    end

    describe 'POST #sort' do
      it 'should not change category order' do
        order_params = { '0' => { id: category2.id, position: 1 }, '1' => { id: category1.id, position: 2 } }
        post :sort, params: { order: order_params }
        expect(category1.reload.category_order).to eq(nil)
        expect(category2.reload.category_order).to eq(2)
      end
    end

    describe 'POST #toggle' do
      it 'should disable enabled category' do
        expect(category1.enabled).to be true
        post :toggle, params: { category_id: category1 }, format: 'js'
        expect(category1.reload.enabled).to be true
      end
    end
  end
end
