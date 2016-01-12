class HomeController < ApplicationController

  def index
    @courses = Course.includes(:lessons).where(pub_status: "P")
  end

  def language_toggle
    session[:locale] = params["format"]
    redirect_to :back
  end

end
