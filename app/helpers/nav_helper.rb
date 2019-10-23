module NavHelper
  def nav_links
    [user_greeting, dashboard_link, www_trainers_link, org_trainers_link,
     my_courses_link, all_courses_link, sign_out_link].compact.join(' | ').html_safe
  end

  def user_greeting
    if is_org_admin?(current_user)
      "#{t('logged_in_user.hi')} Admin!"
    else
      "#{t('logged_in_user.hi')} #{current_user.profile.first_name}!"
    end
  end

  def dashboard_link
    link_to t('logged_in_user.dashboard'), dashboard_location, class: "inline_link"
  end

  def dashboard_location
    if is_org_admin?(current_user)
      admin_dashboard_index_path
    else
      profile_path
    end
  end

  def www_trainers_link
    link_to t('home.trainer_link'),
      "https://training.digitallearn.org",
      target: "_blank",
      class: "inline_link"
  end

  def org_trainers_link
    if current_user.has_role?(:trainer, current_organization)
      link_to t('home.org_trainer_link'), trainer_dashboard_index_path, class: "inline_link"
    end
  end

  def my_courses_link
    unless is_org_admin?(current_user)
      link_to t('logged_in_user.my_courses'), my_courses_path, class: "inline_link"
    end
  end

  def all_courses_link
    unless is_org_admin?(current_user)
      link_to t('logged_in_user.all_courses'), root_path, class: "inline_link"
    end
  end

  def sign_out_link
    link_to "#{t('logged_in_user.sign_out')}", destroy_user_session_path, method: "delete", class: "inline_link"
  end
end