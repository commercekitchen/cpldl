class ProfilesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user

  def show
    @profile = Profile.find_or_initialize_by(user: @user)
  end

  def update
    # Try to update devise fields first, then other fields if successful.
    update_user(devise_params)
    @profile = Profile.find_or_initialize_by(user: @user)
    if @user.errors.any?
      respond_to do |format|
        format.html { render :show }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    else
      respond_to do |format|
        if @profile.update(profile_params[:profile_attributes])
          format.html { redirect_to profile_path, notice: "Profile was successfully updated." }
          format.json { render :show, status: :ok, location: @profile }
        else
          format.html { render :show }
          format.json { render json: @profile.errors, status: :unprocessable_entity }
        end
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
          sign_in :user, user, bypass: true
        end
      end
    else
      if user.update(params)
        sign_in :user, user, bypass: true
      end
    end
  end

  def devise_params
    params.required(:user).permit(:email, :password, :password_confirmation)
  end

  def profile_params
    params.required(:user).permit(profile_attributes: [:id, :first_name, :last_name, :zip_code])
  end

end
