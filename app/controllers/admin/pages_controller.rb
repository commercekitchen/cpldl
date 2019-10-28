module Admin
  class PagesController < BaseController
    before_action :enable_sidebar

    def index
      @cms_pages = CmsPage.where(organization_id: current_organization.id)
      render 'admin/cms_pages/index'
    end
  end
end
