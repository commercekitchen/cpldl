# frozen_string_literal: true

require 'rails_helper'

describe Admin::CmsPagesController do
  let(:cms_page) { FactoryBot.create(:cms_page, title: 'page') }
  let(:org) { cms_page.organization }
  let(:admin) { FactoryBot.create(:user, :admin, organization: org) }

  before(:each) do
    request.host = "#{org.subdomain}.example.com"
    sign_in admin
  end

  describe 'GET #new' do
    it 'assigns a new page as page' do
      get :new
      expect(assigns(:cms_page)).to be_a_new(CmsPage)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested page as page' do
      get :edit, params: { id: cms_page.to_param }
      expect(assigns(:cms_page)).to eq(cms_page)
    end
  end

  describe 'PATCH #update_pub_status' do
    it 'updates the status' do
      patch :update_pub_status, params: { cms_page_id: cms_page.id.to_param, value: 'P' }
      cms_page.reload
      expect(cms_page.pub_status).to eq('P')
    end

    it 'updates the pub_date if status is published' do
      Timecop.freeze do
        patch :update_pub_status, params: { cms_page_id: cms_page.id.to_param, value: 'A' }
        cms_page.reload
        expect(cms_page.pub_date).to be(nil)

        patch :update_pub_status, params: { cms_page_id: cms_page.id.to_param, value: 'P' }
        cms_page.reload
        expect(cms_page.pub_date.to_i).to eq(Time.zone.now.to_i)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      { title: 'This old page',
        body: 'Would you hold it against me?',
        language_id: @english.id,
        author: 'Bob Snob',
        audience: 'Auth',
        pub_status: 'D',
        pub_date: nil,
        seo_page_title: 'A New Page',
        meta_desc: 'Meta This and That',
        organization_id: org.id }
    end

    let(:invalid_attributes) do
      { title: '',
        author: '',
        audience: '',
        pub_status: '',
        seo_page_title: '',
        meta_desc: 'Meta This and That' }
    end

    context 'with valid params' do
      it 'creates a new page' do
        expect do
          post :create, params: { cms_page: valid_attributes, commit: 'Save Page' }
        end.to change(CmsPage, :count).by(1)
      end

      it 'assigns a newly created page as page' do
        post :create, params: { cms_page: valid_attributes, commit: 'Save Page' }
        expect(assigns(:cms_page)).to be_a(CmsPage)
        expect(assigns(:cms_page)).to be_persisted
      end

      it 'redirects to the admin edit view of the page' do
        post :create, params: { cms_page: valid_attributes, commit: 'Save Page' }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_admin_cms_page_path(CmsPage.find_by(title: valid_attributes[:title])))
      end

      it 'renders a preview of page' do
        post :create, params: { cms_page: valid_attributes, commit: 'Preview Page' }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end

      it 'sets the pub_date if page is saved as (P)ublished' do
        valid_attributes[:pub_status] = 'P'
        Timecop.freeze do
          post :create, params: { cms_page: valid_attributes, commit: 'Save Page' }
          page = CmsPage.find_by(title: valid_attributes[:title])
          expect(page.pub_date.to_i).to eq(Time.zone.now.to_i)
        end
      end
    end

    context 'with invalid params' do
      it 'does not create a page with invalid attributes' do
        expect do
          post :create, params: { cms_page: invalid_attributes, commit: 'Save Page' }
        end.to change(CmsPage, :count).by(0)
      end

      it "re-renders the 'new' template" do
        post :create, params: { cms_page: invalid_attributes, commit: 'Save Page' }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST #update' do
    context 'with valid params' do
      it 'updates an existing page' do
        patch :update, params: { id: cms_page.to_param, cms_page: cms_page.attributes, commit: 'Save Page' }
        expect(response).to redirect_to(edit_admin_cms_page_path(cms_page))
      end

      it 'updates pub_date if pub_status changes' do
        Timecop.freeze do
          patch :update, params: { id: cms_page.to_param, cms_page: { pub_status: 'P' }, commit: 'Save Page' }
          cms_page.reload
          expect(cms_page.pub_date.to_i).to eq(Time.zone.now.to_i)

          patch :update, params: { id: cms_page.to_param, cms_page: { pub_status: 'D' }, commit: 'Save Page' }
          cms_page.reload
          expect(cms_page.pub_date).to eq(nil)
        end
      end

      it 'renders a preview of page' do
        patch :update, params: { id: cms_page.to_param, cms_page: cms_page.attributes, commit: 'Preview Page' }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end

      it 're-renders edit if update fails' do
        patch :update, params: { id: cms_page.to_param, cms_page: { title: nil }, commit: 'Save Page' }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'success' do
      it 'deletes a page' do
        expect { delete :destroy, params: { id: cms_page.to_param } }.to change(CmsPage, :count).by(-1)
      end
    end
  end

  describe 'POST #sort' do
    let!(:cms_page_2) { FactoryBot.create(:cms_page, title: 'Page2', organization: org) }

    it 'should change cms_page order' do
      order_params = { '0' => { id: cms_page_2.id, position: 1 }, '1' => { id: cms_page.id, position: 2 } }
      post :sort, params: { order: order_params }
      expect(cms_page.reload.cms_page_order).to eq(2)
      expect(cms_page_2.reload.cms_page_order).to eq(1)
    end
  end
end
