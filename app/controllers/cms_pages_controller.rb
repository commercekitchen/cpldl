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

class CmsPagesController < ApplicationController
  before_action :find_cms_page

  def show
    @cms_page_body = @cms_page.body.html_safe
  end

  def find_cms_page
    @cms_page = CmsPage.friendly.find(params[:id])
    if request.path != cms_page_path(@cms_page)
      redirect_to @cms_page, status: :moved_permanently
    end
  end
end
