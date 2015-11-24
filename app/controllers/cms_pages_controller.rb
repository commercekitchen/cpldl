class CmsPagesController < ApplicationController
  def show
    @cms_page = CmsPage.friendly.find(params[:id])
  end
end