class Admin::Custom::UserSurveysController < Admin::Custom::BaseController
  before_action :load_ogranization
  layout "admin/base_with_sidebar"

  def show
    key = "course_completion_page.#{current_organization.subdomain}.user_survey_button_text"
    @en_translation = Translation.find_or_initialize_by(locale: 'en', key: key)
    @es_translation = Translation.find_or_initialize_by(locale: 'es', key: key)
  end

  def update
    if @organization.update(org_params) & update_translations
      flash[:info] = 'Organization user survey updated.'
      redirect_to admin_custom_user_surveys_path
    else
      flash[:error] = @organization.invalid? ? @organization.errors.full_messages : @translation_errors.flatten
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

  def update_translations
    @translation_errors = []
    params.require(:translation).permit!.each do |locale, values|
      translation = values[:id].blank? ? Translation.new : Translation.find(values[:id])
      unless translation.update(values)
        @translation_errors << translation.errors.full_messages
        return false
      end
    end
    true
  end
end
