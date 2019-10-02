class AccountsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user
  layout "user/logged_in_with_sidebar"

  def show
  end

  def update
    update_user(user_params)
    respond_to do |format|
      if @user.errors.any?
        format.html { render :show }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      else
        format.html { redirect_to account_path, notice: "Account was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def update_user(params)
    email = params[:email]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    user = current_user

    if password.blank? && password_confirmation.blank?
      if user.email != email
        if user.update(email: email)
          bypass_sign_in user
        end
      end
    else
      if user.update(params)
        bypass_sign_in user
      end
    end
  end

  def user_params
    params.required(:user).permit(:email, :password, :password_confirmation)
  end

end
