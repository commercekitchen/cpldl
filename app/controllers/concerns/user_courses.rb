module UserCourses
  extend ActiveSupport::Concern

  def authorized_courses
    @courses ||= begin
      courses = Course.includes(:lessons)
                      .where(pub_status: "P", language_id: current_language_id, organization: current_organization)
      courses = courses.everyone unless user_signed_in?
      courses = courses.where(display_on_dl: true) if top_level_domain?
      courses
    end
  end

  def load_category_courses
    @category_ids = current_organization.categories.enabled.map(&:id)
    @disabled_category_ids = current_organization.categories.disabled.map(&:id)
    @disabled_category_courses = @courses.where(category_id: @disabled_category_ids)
    @uncategorized_courses = @courses.where(category_id: nil) + @disabled_category_courses
  end

  def current_language_id
    english_id = Language.find_by_name("English").id || 1
    spanish_id = Language.find_by_name("Spanish").id || 2

    I18n.locale == :es ? spanish_id : english_id
  end
end
