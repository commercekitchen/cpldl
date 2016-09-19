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

  # Is it a subsite? Could be used for *all* subsites or in conjunction with site-specific functions
  def subsite
      Rails.application.config.subdomain_site != 'www'
  end

  # Is is the Chicago subsite?
  def chicago_subsite
    Rails.application.config.subdomain_site == 'chipublib'
   end

   # Is is the demo subsite?
  def demo_subsite
    Rails.application.config.subdomain_site == 'demo'
   end

  def button_color
    if chicago_subsite
      "btn-mustard"
    else
      "btn-blue"
    end

  end

  def hover_color_class
    chicago_subsite == true ? "cpl-blue" : ""
  end

  def color_class
    chicago_subsite == true ? "cpl-blue-block" : ""
  end

  def text_color_class
    chicago_subsite == true ? "cpl-blue-text" : ""
  end

  def link_color_class
    chicago_subsite == true ? "cpl-purple-text" : ""
  end

  def icon_color_class
    chicago_subsite == true ? "cpl-blue" : ""
  end

  def download_color_class
    chicago_subsite == true ? "cpl-purple" : ""
  end

  def cert_color_class
    chicago_subsite == true ? "cpl-blue" : ""
  end

  def ck_color_class
    chicago_subsite == true ? "ck-chipublib" : ""
  end

  def widget_color_class
    chicago_subsite == true ? "course-widget-cpl" : "course-widget"
  end
end
