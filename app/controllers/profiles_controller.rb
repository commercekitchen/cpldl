# frozen_string_literal: true

# == Schema Information
#
# Table name: profiles
#
#  id                  :integer          not null, primary key
#  first_name          :string
#  zip_code            :string
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  language_id         :integer
#  library_location_id :integer
#

class ProfilesController < ApplicationController
  skip_before_action :require_valid_profile
  before_action :authenticate_user!
  before_action :set_user
  before_action :enable_sidebar

  def show
    @profile = Profile.find_or_initialize_by(user: @user)
  end

  def invalid_profile
    @profile = Profile.find_or_initialize_by(user: @user)
    @profile.valid?
    render 'show'
  end

  def update
    @profile = Profile.find_or_initialize_by(user: @user)

    if params[:profile][:user].present?
      new_role = params[:profile][:user][:user_role_string] == 'Student' ? 'Student' : 'Parent'
      @user.add_role(new_role)
    end

    profile_params.merge!(updated_at: Time.zone.now) if first_time_login?

    new_profile_params = if current_organization.accepts_custom_branches?
                           convert_branch_params(profile_params)
                         else
                           profile_params
                         end

    language_changed = @profile.language_id != profile_params[:language_id].try(:to_i)

    respond_to do |format|
      if @profile.context_update(new_profile_params)
        update_locale if language_changed
        format.html { redirect_to redirect_path, notice: I18n.t('profile.updated') }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :show }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    @profile_params ||= params.require(:profile).permit(allowed_profile_params)
  end

  def allowed_profile_params
    allowed_params = %i[
      language_id
      first_name
      last_name
      phone
      street_address
      city
      state
      zip_code
      opt_out_of_recommendations
      library_location_id
    ]

    if current_organization.accepts_custom_branches?
      allowed_params << [
        library_location_attributes: %i[
          name
          custom
          zipcode
        ]
      ]
    end

    allowed_params
  end

  def show_quiz?
    current_user.present? &&
      current_user.quiz_modal_complete == false &&
      params[:profile][:opt_out_of_recommendations] != 'true' &&
      !current_user.has_role?(:admin, current_organization)
  end

  def update_locale
    language = Language.find_by(id: @profile.language_id) || Language.first
    I18n.locale = case language.name
                  when 'Spanish'
                    :es
                  else
                    :en
                  end
    session[:locale] = I18n.locale.to_s
  end

  def convert_branch_params(profile_params)
    if profile_params[:library_location_id].present?
      profile_params.except(:library_location_attributes)
    else
      library_location_zip = profile_params[:zip_code].presence || '00000'
      profile_params[:library_location_attributes][:zipcode] = library_location_zip
      profile_params
    end
  end

  def redirect_path
    if first_time_login?
      show_quiz? ? new_quiz_response_path : root_path
    else
      profile_path
    end
  end

end
