module Admin
  class DashboardController < BaseController

    def index
      @courses = Course.includes(:language).all
      render "admin/courses/index", layout: "admin/base_with_sidebar"
    end

    def pages_index
      @cms_pages = CmsPage.all
      render "admin/cms_pages/index", layout: "admin/base_with_sidebar"
    end

    def users_index
      results = User.search_users(params[:search])
      @users  = params[:search].blank? ? User.all : results

      render "admin/users/index", layout: "admin/base_with_sidebar"
    end

    def manually_confirm_user
      User.find(params[:user_id]).confirm if current_user.has_role? :admin
      redirect_to admin_users_index_path
    end

    def import_courses
      @all_subsite_ids = Course.where(subsite_course: true).pluck(:id)
      @previously_imported_ids = Course.all.pluck(:parent_id).compact
      @unadded_course_ids = @all_subsite_ids - @previously_imported_ids
      @importable_courses = Course.where(id: @unadded_course_ids)
      respond_to do |format|
        format.html do
          render "admin/courses/import_courses", layout: "admin/base_with_sidebar"
        end
      end
    end

    def add_imported_course
      course_to_import = Course.find(params["course_id"].to_i)
      new_course = course_to_import.dup
      new_course.parent_id = course_to_import.id
      new_course.subsite_course = false
      new_course.pub_date = nil
      new_course.pub_status = "D"
      new_course.save

      course_to_import.lessons.each do |imported_lesson|
        new_lesson = imported_lesson.dup
        new_lesson.course_id = new_course.id
        new_lesson.story_line = nil
        new_lesson.story_line = imported_lesson.story_line
        new_lesson.save
        Unzipper.new(new_lesson.story_line)
      end
      redirect_to edit_admin_course_path(new_course)
    end
  end
end
