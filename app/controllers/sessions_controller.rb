class SessionsController < Devise::SessionsController
  def new
    @library_card_login = current_organization.library_card_login? && !params[:admin]
    super
  end
end
