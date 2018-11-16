class SessionsController < Devise::SessionsController
  prepend_before_filter :hash_library_card_pin, only: [:create]

  private

    def hash_library_card_pin
      if current_organization.library_card_login?
        request.params[:user][:password] = Digest::MD5.hexdigest(params[:user][:password]).first(10)
      end
    end
end
