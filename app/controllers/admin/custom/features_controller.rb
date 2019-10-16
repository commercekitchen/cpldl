# frozen_string_literal: true

class Admin::Custom::FeaturesController < Admin::Custom::BaseController
  before_action :load_ogranization
  layout 'admin/base_with_sidebar'

  def show; end

  def update
    if @organization.update(org_params)
      flash[:info] = 'Organization Login Requirement Updated.'
      redirect_to admin_custom_features_path
    else
      flash[:error] = @organization.errors.full_messages
      render :show
    end
  end

  private

  def load_ogranization
    @organization = current_organization
  end

  def org_params
    params.require(:organization).permit(:login_required)
  end
end
