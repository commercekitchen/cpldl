# frozen_string_literal: true

class CmsPagesController < ApplicationController
  before_action :find_cms_page

  def show
    skip_authorization
    @cms_page_body = @cms_page.body.html_safe
  end

  def find_cms_page
    @cms_page = CmsPage.friendly.find(params[:id])
    if request.path != cms_page_path(@cms_page)
      redirect_to @cms_page, status: :moved_permanently
    end
  end
end
