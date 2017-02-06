module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def show_quiz?
    current_user.present? && current_user.quiz_modal_complete == false && !current_user.profile.opt_out_of_recommendations && !current_user.has_role?(:admin, current_organization)
  end
end
