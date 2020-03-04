# frozen_string_literal: true

module Admin
  class CoursesController < BaseController

    before_action :set_course, only: %i[preview edit update destroy]
    before_action :set_maximums, only: %i[new edit]
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
    end

    def create
      @course = current_organization.courses.new(new_course_params)

      authorize @course

      if params[:course][:pub_status] == 'P'
        @course.set_pub_date
      end

      @course.org_id = current_user.organization_id

      if @course.save
        @course.topics_list(build_topics_list(params))
        if params[:commit] == 'Save Course'
          redirect_to edit_admin_course_path(@course), notice: 'Course was successfully created.'
        else
          redirect_to new_admin_course_lesson_path(@course), notice: 'Course was successfully created. Now add some lessons.'
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
      course.update_lesson_pub_stats(params[:value])

      if course.save
        render status: :ok, json: course.pub_status.to_s
      else
        render status: :unprocessable_entity, json: 'post failed to update'
      end
    end

    def update
      authorize @course

      # The slug must be set to nil for the friendly_id to update on title change
      @course.slug = nil if @course.title != params[:course][:title]

      @course.update_pub_date(params[:course][:pub_status]) if params[:course][:pub_status] != @course.pub_status

      if @course.update(new_course_params)
        @course.topics_list(build_topics_list(params))

        changed = propagate_changes? ? propagate_course_changes.count : 0
        success_message = 'Course was successfully updated.'
        success_message += " Changes propagated to courses for #{changed} #{'subsite'.pluralize(changed)}." if propagate_changes?

        case params[:commit]
        when 'Save Course'
          redirect_to edit_admin_course_path(@course), notice: success_message
        when 'Save Course and Edit Lessons'
          redirect_to edit_admin_course_lesson_path(@course, @course.lessons.first), notice: success_message
        else
          redirect_to new_admin_course_lesson_path(@course), notice: success_message
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

    def set_maximums
      @max_title   = Course.validators_on(:title).first.options[:maximum]
      @max_seo     = Course.validators_on(:seo_page_title).first.options[:maximum]
      @max_summary = Course.validators_on(:summary).first.options[:maximum]
      @max_meta    = Course.validators_on(:meta_desc).first.options[:maximum]
    end

    def set_course
      id_param = params[:id] || params[:course_id]
      @course = Course.friendly.find(id_param)
    end

    def course_params
      permitted_attributes = [
        :title,
        :seo_page_title,
        :meta_desc,
        :summary,
        :description,
        :contributor,
        :pub_status,
        :language_id,
        :level,
        :topics,
        :notes,
        :delete_document,
        :other_topic,
        :other_topic_text,
        :course_order,
        :pub_date,
        :format,
        :access_level,
        :category_id,
        propagation_org_ids: [],
        category_attributes: %i[name organization_id],
        attachments_attributes: %i[course_id document title doc_type file_description _destroy]
      ]

      params.require(:course).permit(permitted_attributes)
    end

    def new_course_params
      if course_params[:category_id].present? && course_params[:category_id] == '0'
        course_params
      else
        course_params.except(:category_attributes)
      end
    end

    def build_topics_list(params)
      topics_list = params[:course][:topics] || []
      other_topic = params[:course][:other_topic] == '1' ? [params[:course][:other_topic_text]] : []
      topics_list | other_topic
    end

    def propagate_changes?
      @course.propagation_org_ids.delete_if(&:blank?).any? && attributes_to_propagate.any?
    end

    def attributes_to_propagate
      category_name = @course.reload.category.name
      course_params.except(:category_id, :category_attributes, :propagation_org_ids).merge(category_name: category_name).to_h
    end

    def propagate_course_changes
      Course.copied_from_course(@course).each do |course|
        course.update(attributes_to_propagate)
      end
    end
  end
end
