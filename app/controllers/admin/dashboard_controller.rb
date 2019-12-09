# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    before_action :enable_sidebar

    def index
      @courses = Course.org(current_organization).includes(:language).where.not(pub_status: 'A')

      @category_ids = current_organization.categories.map(&:id)
      @uncategorized_courses = @courses.where(category_id: nil)

      render 'admin/courses/index'
    end

    def admin_invitation
      self.resource = resource_class.new
      render 'admin/invites/new'
    end

    def manually_confirm_user
      User.find(params[:user_id]).confirm if current_user.has_role?(:admin, current_organization)
      redirect_to admin_users_path
    end

    def import_courses
      @all_subsite_ids = Course.where(pub_status: 'P', subsite_course: true).pluck(:id)
      @previously_imported_ids = current_organization.courses.where.not(pub_status: 'A').pluck(:parent_id).compact
      @unadded_course_ids = @all_subsite_ids - @previously_imported_ids
      @importable_courses = Course.where(id: @unadded_course_ids)

      @category_ids = Organization.find_by(subdomain: 'www').categories.map(&:id)
      @uncategorized_courses = @importable_courses.where(category_id: nil)

      respond_to do |format|
        format.html do
          render 'admin/courses/import_courses'
        end
      end
    end

    def add_imported_course
      import_service = CourseImportService.new(organization: current_organization, course_id: params['course_id'].to_i)
      new_course = import_service.import!

      redirect_to edit_admin_course_path(new_course)
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_import_courses_path, alert: e.record.errors.full_messages
    end

  end
end
