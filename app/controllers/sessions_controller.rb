# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  def new
    skip_authorization
    @library_card_login = current_organization.library_card_login? && !params[:admin]
    super
  end
end
