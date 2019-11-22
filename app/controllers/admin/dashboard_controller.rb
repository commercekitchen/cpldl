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
      new_course = nil

      ActiveRecord::Base.transaction do
        course_to_import = Course.find(params['course_id'].to_i)
        new_course = course_to_import.dup
        new_course.parent_id = course_to_import.id
        new_course.subsite_course = false
        new_course.pub_date = nil
        new_course.pub_status = 'D'
        new_course.category_id = new_or_existing_subsite_category_id(course_to_import.category)
        new_course.organization = current_organization
        new_course.save!

        # Create copies of the lessons and ASLs
        course_to_import.lessons.each do |imported_lesson|
          new_lesson = imported_lesson.dup
          new_lesson.parent_id = imported_lesson.id
          new_lesson.course_id = new_course.id
          new_lesson.story_line = nil
          new_lesson.story_line = imported_lesson.story_line
          new_lesson.save!
        end

        # Create copies of the attachments
        course_to_import.attachments.each do |attachment|
          new_attachment = attachment.dup
          new_attachment.document = attachment.document
          new_attachment.course_id = new_course.id
          new_attachment.save!
        end

        # Create copies of the topics
        course_to_import.course_topics.each do |course_topic|
          new_topic = course_topic.dup
          new_topic.course_id = new_course.id
          new_topic.save!
        end
      end

      redirect_to edit_admin_course_path(new_course)
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_import_courses_path, alert: e.record.errors.full_messages
    end

    private

    def new_or_existing_subsite_category_id(category)
      return nil if category.blank?

      current_user.organization.categories.each do |org_category|
        if org_category.name.downcase == category.name.downcase
          @subsite_category_id = org_category.id
        end
      end
      @subsite_category_id || current_user.organization.categories.create(name: category.name).id
    end

  end
end
