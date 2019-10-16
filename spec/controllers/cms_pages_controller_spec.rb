# frozen_string_literal: true

# == Schema Information
#
# Table name: cms_pages
#
#  id              :integer          not null, primary key
#  title           :string(90)
#  author          :string
#  audience        :string
#  pub_status      :string           default("D")
#  pub_date        :datetime
#  seo_page_title  :string(90)
#  meta_desc       :string(156)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  slug            :string
#  cms_page_order  :integer
#  language_id     :integer
#  body            :text
#  organization_id :integer
#

require 'rails_helper'

describe CmsPagesController do
  before(:each) do
    create(:default_organization)
    @request.host = 'www.test.host'
    @english = FactoryBot.create(:language)
    @spanish = FactoryBot.create(:spanish_lang)
    @cms_page = FactoryBot.create(:cms_page)
  end

  describe 'GET #show' do
    it 'assigns the requested page (by id) as @cms_page' do
      get :show, params: { id: @cms_page.to_param }
      expect(assigns(:cms_page)).to eq(@cms_page)
    end

    it 'assigns the requested cms_page (by friendly id) as @cms_page' do
      get :show, params: { id: @cms_page.friendly_id }
      expect(assigns(:cms_page)).to eq(@cms_page)
    end

    it 'allows the admin to change the title, and have the old title redirect to the new title' do
      old_url = @cms_page.friendly_id
      @cms_page.slug = nil # Must set slug to nil for the friendly url to regenerate
      @cms_page.title = 'New Title'
      @cms_page.save

      get :show, params: { id: old_url }
      expect(assigns(:cms_page)).to eq(@cms_page)
      expect(response).to have_http_status(:redirect)

      get :show, params: { id: @cms_page.friendly_id }
      expect(assigns(:cms_page)).to eq(@cms_page)
    end
  end
end
