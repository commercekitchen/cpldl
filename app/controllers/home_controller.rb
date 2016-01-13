class HomeController < ApplicationController

  def index
    case I18n.locale
    when :es
      @courses = Course.includes(:lessons).where(pub_status: "P", language_id: 2)
    else
      @courses = Course.includes(:lessons).where(pub_status: "P", language_id: 1)
    end
  end

  def language_toggle
    session[:locale] = params["lang"]
    redirect_to :back
  end

end
