class Admin::Custom::OrganizationsController < Admin::Custom::BaseController
  before_action :load_ogranization, except: :show

  def show
  end

  def footer
    render layout: "admin/base_with_sidebar"
  end

  def update
    if @organization.update(org_params)
      flash[:info] = 'Organization preferences updated.'
    else
      flash[:error] = @organization.errors.full_messages
    end

    redirect_to send("#{params[:page]}_admin_custom_organizations_path") || admin_customization_path
  end

  private

  def load_ogranization
    @organization = current_organization
  end

  def org_params
    params.require(:organization).permit(:footer_logo_link, :footer_logo)
  end
end
