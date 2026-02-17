class SpaController < ActionController::Base
  def index
    render :index, layout: 'spa'
  end
end
