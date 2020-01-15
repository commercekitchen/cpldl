# frozen_string_literal: true

require 'rails_helper'

describe Admin::Custom::TranslationsController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

  before(:each) do
    @request.host = "#{organization.subdomain}.test.host"
    sign_in admin
  end

  after(:each) do
    I18n.locale = :en
  end

  describe '#index' do
    let!(:en_translation1) { FactoryBot.create(:translation) }
    let!(:en_translation2) { FactoryBot.create(:translation) }
    let!(:es_translation1) { FactoryBot.create(:translation, locale: :es) }
    let!(:es_translation2) { FactoryBot.create(:translation, locale: :es) }

    it 'should assign en translations' do
      I18n.locale = :en
      get :index
      expect(assigns(:translations)).to contain_exactly(en_translation1, en_translation2)
    end

    it 'should assign es translations' do
      I18n.locale = :es
      get :index
      expect(assigns(:translations)).to contain_exactly(es_translation1, es_translation2)
    end
  end

  describe '#new' do
    let(:send_request) { get :new, params: { key: 'foobar' } }

    it 'should build a new translation' do
      send_request
      expect(assigns(:translation)).to be_a_new(Translation)
    end
  end

  describe '#create' do
    describe 'translation matches default' do
      let(:translation_key) { 'home.www.custom_banner_greeting' }
      let(:default_translation_value) { I18n.t(translation_key, locale: :en) }
      let(:default_translation_params) do
        { i18n_backend_active_record_translation: { locale: :en, key: translation_key, value: default_translation_value } }
      end

      let(:send_request) { post :create, params: default_translation_params }

      it 'should not create a Translation' do
        expect do
          send_request
        end.to_not change(Translation, :count)
      end

      it 'should assign correct flash' do
        send_request
        expect(flash[:alert]).to eq('Your new translation is the same as the default.')
      end

      it 'should render new' do
        send_request
        expect(response).to render_template(:new)
      end
    end

    describe 'successful translation' do
      let(:translation_key) { "home.#{organization.subdomain}.custom_banner_greeting" }
      let(:translation_value) { Faker::Lorem.word }
      let(:translation_params) do
        { i18n_backend_active_record_translation: { locale: :en, key: translation_key, value: translation_value } }
      end

      let(:send_request) { post :create, params: translation_params }

      it 'should create a Translation' do
        expect do
          send_request
        end.to change(Translation, :count).by(1)
      end

      it 'should assign correct flash' do
        send_request
        expect(flash[:success]).to eq('Text for Homepage Greeting updated.')
      end

      it 'should redirect to translations index' do
        send_request
        expect(response).to redirect_to admin_custom_translations_path(:en)
      end
    end

    describe 'invalid translation' do
      let(:invalid_translation_params) do
        { i18n_backend_active_record_translation: { locale: :en } }
      end

      let(:send_request) { post :create, params: invalid_translation_params }

      before do
        expect_any_instance_of(Translation).to receive(:save).and_return(false)
      end

      it 'should not create a translation' do
        expect do
          send_request
        end.to_not change(Translation, :count)
      end

      it 'should render new' do
        send_request
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#update' do
    let(:translation_key) { "home.#{organization.subdomain}.custom_banner_greeting" }
    let!(:translation) { FactoryBot.create(:translation, key: translation_key) }

    describe 'successful update' do
      let(:translation_value) { "#{translation.value}_new" }

      let(:translation_params) do
        { id: translation.id, i18n_backend_active_record_translation: { locale: :en, key: translation_key, value: translation_value } }
      end

      let(:send_request) { post :update, params: translation_params }

      it 'should update translation value' do
        send_request
        expect(translation.reload.value).to eq(translation_value)
      end

      it 'should assign correct flash' do
        send_request
        expect(flash[:notice]).to eq('Text for Homepage Greeting updated.')
      end

      it 'should redirect to translations index' do
        send_request
        expect(response).to redirect_to admin_custom_translations_path(:en)
      end
    end

    describe 'failed update' do
      let(:invalid_translation_params) do
        { id: translation.id, i18n_backend_active_record_translation: { locale: :en } }
      end

      let(:send_request) { post :update, params: invalid_translation_params }

      before do
        expect_any_instance_of(Translation).to receive(:update).and_return(false)
      end

      it 'should render edit' do
        send_request
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    let!(:translation) { FactoryBot.create(:translation) }

    let(:send_request) { delete :destroy, params: { id: translation.id } }

    it 'should remove translation' do
      expect do
        send_request
      end.to change(Translation, :count).by(-1)
    end

    it 'should redirect to translations index' do
      send_request
      expect(response).to redirect_to(admin_custom_translations_path(:en))
    end
  end
end
