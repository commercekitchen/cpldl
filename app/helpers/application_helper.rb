module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def subdomain
    @subdomain =  Rails.application.config.subdomain_site
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def course_urls
    %w(/ /courses /courses/your)
  end

  def chicago
    Rails.application.config.chicago == true
  end

  def button_color
    if chicago
      "btn-mustard"
    else
      "btn-blue"
    end

  end

  def hover_color_class
    chicago = true ? "cpl-blue" : ""
  end

  def color_class
    chicago = true ? "cpl-blue-block" : ""
  end

  def text_color_class
    chicago = true ? "cpl-blue-text" : ""
  end

  def link_color_class
    chicago = true ? "cpl-purple-text" : ""
  end

  def icon_color_class
    chicago = true ? "cpl-blue" : ""
  end

  def download_color_class
    chicago = true ? "cpl-purple" : ""
  end

  def cert_color_class
    chicago = true ? "cpl-blue" : ""
  end

  def ck_color_class
    chicago = true ? "ck-chipublib" : ""
  end

  def widget_color_class
    chicago = true ? "course-widget-cpl" : "course-widget"
  end
end
