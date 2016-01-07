class HomeController < ApplicationController

  def index
    @courses = Course.includes(:lessons).where(pub_status: "P")
  end

end
