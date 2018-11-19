class LoginController < ApplicationController
  def new
    @library_card_login = current_organization.library_card_login? && !params[:admin]
  end
end
