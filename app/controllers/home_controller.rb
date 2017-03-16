class HomeController < ApplicationController
  skip_before_action :require_valid_profile, only: [:language_toggle]

  def index
    english_id = Language.find_by_name("English").id || 1
    spanish_id = Language.find_by_name("Spanish").id || 2
    case I18n.locale
    when :es
      if top_level_domain?
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: spanish_id, display_on_dl: true).where_exists(:organization, subdomain: current_organization.subdomain)
      else
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: spanish_id).where_exists(:organization, subdomain: current_organization.subdomain)
      end
    else
      if top_level_domain?
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: english_id, display_on_dl: true).where_exists(:organization, subdomain: current_organization.subdomain)
      else
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: english_id).where_exists(:organization, subdomain: current_organization.subdomain)
      end
    end

    @category_ids = current_organization.categories.map(&:id)
    @uncategorized_courses = @courses.where(category_id: nil)
  end

  def language_toggle
    session[:locale] = params["lang"]
    redirect_to :back
  end
end
