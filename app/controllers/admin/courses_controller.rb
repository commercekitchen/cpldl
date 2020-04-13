# frozen_string_literal: true

module Admin
  class CoursesController < BaseController
    before_action :set_course, only: %i[preview edit update destroy]
    before_action :set_category_options, only: %i[new edit create update]

    def index
      @courses = policy_scope(Course)

      @category_ids = current_organization.categories.map(&:id)
      @uncategorized_courses = @courses.where(category_id: nil)

      enable_sidebar
    end

    def preview
      authorize @course
      @preview = true
      render 'courses/show'
    end

    def new
      @course = Course.new(organization: current_organization)
      authorize @course

      @category = @course.category.build if params[:category].present?
    end

    def edit
      authorize @course
      @imported_course = @course.parent.present?
    end

    def create
      @course = current_organization.courses.new

      authorize @course

      @course.assign_attributes(new_course_params)

      if @course.save
        if params[:commit] == 'Save & Edit Lessons'
          redirect_to new_admin_course_lesson_path(@course), notice: 'Course was successfully created. Now add some lessons.'
        else
          redirect_to edit_admin_course_path(@course), notice: 'Course was successfully created.'
        end
      else
        @course.errors.delete(:"attachments.document_content_type")
        @custom = course_params[:category_id] == '0'
        @custom_category = course_params[:category_attributes][:name] if course_params[:category_attributes].present?
        render :new
      end
    end

    def update_pub_status
      course = Course.find(params[:course_id])
      authorize course, :update?

      course.pub_status = params[:value]
      course.update_pub_date(params[:value])

      if course.save
        render status: :ok, json: course.pub_status.to_s
      else
        render status: :unprocessable_entity, json: 'post failed to update'
      end
    end

    def update
      authorize @course

      @course.slug = nil if @course.title != params[:course][:title]

      if @course.update(new_course_params)
        if @course.parent.blank?
          CoursePropagationService.new(course: @course).propagate_course_changes(attributes_to_propagate)
        end

        success_message = 'Course was successfully updated.'

        case params[:commit]
        when 'Save Course'
          redirect_to edit_admin_course_path(@course), notice: success_message
        when 'Save & Edit Lessons'
          if @course.lessons.blank?
            redirect_to new_admin_course_lesson_path(@course), notice: success_message
          else
            redirect_to edit_admin_course_lesson_path(@course, @course.lessons.first), notice: success_message
          end
        else
          render :edit, alert: 'Unknown Action'
        end
      else
        @course.errors.delete(:"attachments.document_content_type")
        @custom = course_params[:category_id] == '0'
        @custom_category = course_params[:category_attributes][:name] if course_params[:category_attributes].present?

        render :edit
      end
    end

    def sort
      courses = policy_scope(Course)
      SortService.sort(model: courses, order_params: params[:order], attribute_key: :course_order, user: current_user)

      head :ok
    end

    def destroy
      @course.destroy
      redirect_to courses_url, notice: 'Course was successfully destroyed.'
    end

    private

    def set_category_options
      @category_options = Category.where(organization_id: current_user.organization_id).map do |category|
        [category.admin_display_name, category.id]
      end

      @category_options << ['Create new category', 0]
    end

    def set_course
      id_param = params[:id] || params[:course_id]
      @course = Course.friendly.find(id_param)
    end

    def course_params
      params.require(:course).permit(policy(@course).permitted_attributes)
    end

    def new_course_params
      @new_course_params ||= if course_params[:category_id].present? && course_params[:category_id] == '0'
                               course_params
                             else
                               course_params.except(:category_attributes)
                             end
    end

    def attributes_to_propagate
      course_params.except(:category_id, :category_attributes, :access_level, :course_topics_attributes, :attachments_attributes, :pub_status, :notes)
    end
  end
end
