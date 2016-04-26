module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def subdomain
    @subdomain = request.subdomain
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def course_urls
    %w(/ /courses /courses/your)
  end

  def button_color
    request.subdomain == "chipublib" ? "btn-mustard" : ""
  end
end
