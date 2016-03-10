module Admin
  class DashboardController < BaseController

    def index
      @courses = Course.includes(:language).where_exists(:organization_course, organization_id: current_user.organization_id)
      render "admin/courses/index", layout: "admin/base_with_sidebar"
    end

    def pages_index
      @cms_pages = CmsPage.where(organization_id: Organization.find_by_subdomain(request.subdomain).id)
      render "admin/cms_pages/index", layout: "admin/base_with_sidebar"
    end

    def invites_index
      render "admin/invites/new", layout: "admin/base_with_sidebar"
    end

    def users_index
      results = User.search_users(params[:search])
      if params[:search].blank?
        @users = User.includes(profile: [:language]).with_any_role({ name: :user, resource: current_user.organization }, { name: :admin, resource: current_user.organization })
      else
        @users = results & User.includes(profile: [:language]).({ name: :user, resource: current_user.organization }, { name: :admin, resource: current_user.organization })
      end

      render "admin/users/index", layout: "admin/base_with_sidebar"
    end

    def manually_confirm_user
      User.find(params[:user_id]).confirm if current_user.has_role?(:admin, Organization.find_by_subdomain(request.subdomain))
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
      # Create the course
      course_to_import = Course.find(params["course_id"].to_i)
      new_course = course_to_import.dup
      new_course.parent_id = course_to_import.id
      new_course.subsite_course = false
      new_course.pub_date = nil
      new_course.pub_status = "D"
      new_course.save

      # Create copies of the lessons and ASLs
      course_to_import.lessons.each do |imported_lesson|
        new_lesson = imported_lesson.dup
        new_lesson.course_id = new_course.id
        new_lesson.story_line = nil
        new_lesson.story_line = imported_lesson.story_line
        new_lesson.save
        Unzipper.new(new_lesson.story_line)
      end

      # Create copies of the attachments
      course_to_import.attachments.each do |attachment|
        new_attachment = attachment.dup
        new_attachment.document = attachment.document
        new_attachment.course_id = new_course.id
        new_attachment.save
      end

      # Create copies of the topics
      course_to_import.course_topics.each do |course_topic|
        new_topic = course_topic.dup
        new_topic.course_id = new_course.id
        new_topic.save
      end

      # Create OrganizationCourse Entry
      OrganizationCourse.create(organization_id: current_user.organization_id,
                                course_id: new_course.id)
      redirect_to edit_admin_course_path(new_course)
    end
  end
end
