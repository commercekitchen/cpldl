class SessionsController < Devise::SessionsController
  prepend_before_action :hash_library_card_pin, only: [:create]
  prepend_before_action :set_library_card_login

  private

  def hash_library_card_pin
    if @library_card_login
      request.params[:user][:password] = Digest::MD5.hexdigest(params[:user][:password]).first(10)
    end
  end

  def set_library_card_login
    @library_card_login = current_organization.library_card_login? && !params[:admin]
  end
end
