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

    def manually_confirm_user
      User.find(params[:user_id]).confirm if current_user.has_role? :admin
      redirect_to admin_users_index_path
    end
  end
end
