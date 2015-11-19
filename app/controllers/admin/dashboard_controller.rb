module Admin
  class DashboardController < BaseController

    def index
      @courses = Course.includes(:language).all
      render "admin/courses/index", layout: "admin/base_with_sidebar"
    end

    def pages_index
      @cms_pages = CmsPage.all
      render "admin/cms_pages/index", layout: "admin/base_with_sidebar"
    end

    def users_index
      results = User.search_users(params[:search])
      @users  = params[:search].blank? ? User.all : results

      render "admin/users/index", layout: "admin/base_with_sidebar"
    end
  end
end
