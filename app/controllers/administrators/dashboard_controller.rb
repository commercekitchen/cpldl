class Administrators::DashboardController < Administrators::BaseController

  def index
    @courses = Course.all
  end
end
