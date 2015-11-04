class HomeController < ApplicationController

  def index
    @courses = Course.includes(:lessons).all
  end

end
