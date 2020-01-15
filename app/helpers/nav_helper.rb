# frozen_string_literal: true

module NavHelper
  def nav_links
    [user_greeting, dashboard_link, account_link, org_trainers_link,
     my_courses_link, all_courses_link, sign_out_link].compact
  end

  def user_greeting
    if org_admin?
      "#{t('logged_in_user.hi')} Admin!"
    else
      "#{t('logged_in_user.hi')} #{current_user.profile.first_name}!"
    end
  end

  def dashboard_link
    if org_admin?
      link_to t('admin.dashboard'), admin_dashboard_index_path, class: 'inline_link'
    end
  end

  def account_link
    link_to t('logged_in_user.account'), profile_path, class: 'inline_link'
  end

  def org_trainers_link
    if current_user.has_role?(:trainer, current_organization)
      link_to t('home.org_trainer_link'), trainer_dashboard_index_path, class: 'inline_link'
    end
  end

  def my_courses_link
    unless org_admin?
      link_to t('logged_in_user.my_courses'), my_courses_path, class: 'inline_link'
    end
  end

  def all_courses_link
    unless org_admin?
      link_to t('logged_in_user.all_courses'), root_path, class: 'inline_link'
    end
  end

  def sign_out_link
    link_to t('logged_in_user.sign_out').to_s, destroy_user_session_path, method: 'delete', class: 'inline_link'
  end
end
