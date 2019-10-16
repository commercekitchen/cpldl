# frozen_string_literal: true

class HomeController < ApplicationController
  include UserCourses

  skip_before_action :require_valid_profile, only: [:language_toggle]

  def index
    @courses = authorized_courses
    load_category_courses
  end

  def language_toggle
    session[:locale] = params['lang']
    redirect_back(fallback_location: root_path)
  end
end
