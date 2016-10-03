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

  def course_urls
    %w(/ /courses /courses/your)
  end

  def button_color
    if current_organization.subdomain == 'chipublib'
      "btn-mustard"
    else
      "btn-blue"
    end
  end

  def button_class
    current_organization.subdomain == 'chipublib' ? "btn-mustard" : ""
  end

  def slogan_class
    current_organization.subdomain == 'chipublib' ? "cpl-slogan" : ""
  end

  def hover_color_class
    current_organization.subdomain == 'chipublib' ? "cpl-blue" : ""
  end

  def color_class
    current_organization.subdomain == 'chipublib' ? "cpl-blue-block" : ""
  end

  def text_color_class
    current_organization.subdomain == 'chipublib' ? "cpl-blue-text" : ""
  end

  def link_color_class
    current_organization.subdomain == 'chipublib' ? "cpl-purple-text" : ""
  end

  def icon_color_class
    current_organization.subdomain == 'chipublib' ? "cpl-blue" : ""
  end

  def download_color_class
    current_organization.subdomain == 'chipublib' ? "cpl-purple" : ""
  end

  def cert_color_class
    current_organization.subdomain == 'chipublib' ? "cpl-blue" : ""
  end

  def ck_color_class
    current_organization.subdomain == 'chipublib' ? "ck-chipublib" : ""
  end

  def widget_color_class
    current_organization.subdomain == 'chipublib' ? "course-widget-#{current_organization.subdomain}" : "course-widget"
  end
end
