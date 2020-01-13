# frozen_string_literal: true

class HomeController < ApplicationController
  include UserCourses

  skip_before_action :require_valid_profile, only: [:language_toggle]

  def index
    @courses = authorized_courses
  end

  def language_toggle
    requested_locale = params['lang']
    whitelisted_locales = I18n.available_locales.map(&:to_s)
    session[:locale] = requested_locale if whitelisted_locales.include?(requested_locale)
    redirect_back(fallback_location: root_path)
  end
end
