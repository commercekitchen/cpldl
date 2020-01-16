# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  before_action :skip_authorization

  def new
    @library_card_login = current_organization.library_card_login? && !params[:admin]
    super
  end
end
