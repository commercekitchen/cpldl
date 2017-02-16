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
  layout "user/logged_in_with_sidebar"

  def show
    @profile = Profile.find_or_initialize_by(user: @user)
    @organization_programs = organization_programs
  end

  def invalid_profile
    @profile = Profile.find_or_initialize_by(user: @user)
    @organization_params = organization_programs
    @profile.valid?
    render "show"
  end

  def update
    @profile = Profile.find_or_initialize_by(user: @user)
    @organization_programs = organization_programs

    if params[:profile][:user].present?
      new_role = params[:profile][:user][:user_role_string]

      if new_role == "Student"
        @user.add_role("Student")
      else
        @user.add_role("Parent")
      end
    end

    if first_time_login?
      profile_params.merge!(updated_at: Time.zone.now)
      redirect_path = ( show_quiz? ? courses_quiz_path : root_path ) 
    else
      redirect_path = profile_path
    end

    respond_to do |format|
      if @profile.context_update(profile_params)
        format.html { redirect_to redirect_path, notice: "Profile was successfully updated." }
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
    @profile_params ||= params.require(:profile).permit(:language_id, :first_name, :last_name,
      :phone, :street_address, :city, :state, :zip_code, :opt_out_of_recommendations)
  end

  def organization_programs
    if current_user.organization.accepts_programs?
      Program.for_subdomain(current_organization.subdomain).collect { |program| [ program.program_name, program.id ] }
    end
  end

  def show_quiz?
    current_user.present? && current_user.quiz_modal_complete == false && !current_user.profile.opt_out_of_recommendations && !current_user.has_role?(:admin, current_organization)
  end

end
