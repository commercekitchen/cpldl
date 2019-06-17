class Admin::Custom::UserSurveysController < Admin::Custom::BaseController
  before_action :load_ogranization
  layout "admin/base_with_sidebar"

  def show
  end

  def update
    if @organization.update(org_params)
      flash[:info] = 'Organization user survey updated.'
      redirect_to admin_custom_user_surveys_path
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
    params.require(:organization).permit(:user_survey_link, :user_survey_button_text, :user_survey_enabled)
  end
end
