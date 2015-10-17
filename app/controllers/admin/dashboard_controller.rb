module Admin
  class DashboardController < BaseController

    def index
      @courses = Course.all
    end
  end
end
