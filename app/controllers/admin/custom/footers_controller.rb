# frozen_string_literal: true

class Admin::Custom::FootersController < Admin::Custom::BaseController
  before_action :enable_sidebar

  def show; end

  def update
    if @organization.update(org_params)
      flash[:info] = 'Organization footer updated.'
      redirect_to admin_custom_footers_path
    else
      flash[:error] = @organization.errors.full_messages
      render :show
    end
  end

  private

  def org_params
    params.require(:organization).permit(:footer_logo_link, :footer_logo)
  end
end
