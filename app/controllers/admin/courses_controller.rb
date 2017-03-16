module Admin
  class CoursesController < BaseController

    before_action :set_course, only: [:show, :edit, :update, :destroy]
    before_action :set_maximums, only: [:new, :edit]
    before_action :set_category_options, only: [:new, :edit, :create, :update]

    def index
      @courses = Course.includes(:language)
                        .where_exists(:organization_course, organization_id: current_user.organization_id)
                        .where.not(pub_status: "A")

      @category_ids = current_organization.categories.map(&:id)
      @uncategorized_courses = @courses.where(category_id: nil)

      render layout: "admin/base_with_sidebar"
    end

    def show
      render "courses/show"
    end

    def new
      @course = Course.new
      @category = @course.category.build if params[:category].present?
    end

    def edit

    end

    def create
      if course_params[:category_id].present?
        @course = Course.new(course_params)
      else
        @course = Course.new(course_params.except(:category_attributes))
      end

      if params[:course][:pub_status] == "P"
        @course.set_pub_date
      end

      @course.org_id = current_user.organization_id
      @course.validate_has_unique_title

      if @course.errors.any?
        render :new
      elsif @course.save
        OrganizationCourse.where(organization_id: current_user.organization_id, course_id: @course.id).first_or_create do |org_course|
          org_course.organization_id = current_user.organization_id
          org_course.course_id = @course.id
        end
        @course.topics_list(build_topics_list(params))
        if params[:commit] == "Save Course"
          redirect_to edit_admin_course_path(@course), notice: "Course was successfully created."
        else
          redirect_to new_admin_course_lesson_path(@course), notice: "Course was successfully created. Now add some lessons."
        end
      else
        @custom = course_params[:category_id] == "0"
        @custom_category = course_params[:category_attributes][:name] if course_params[:category_attributes].present?
        render :new
      end
    end

    def update_pub_status
      course            = Course.find(params[:course_id])
      course.pub_status = params[:value]
      course.update_pub_date(params[:value])
      course.update_lesson_pub_stats(params[:value])

      if course.save
        render status: 200, json: "#{course.pub_status}"
      else
        render status: :unprocessable_entity, json: "post failed to update"
      end
    end

    def update
      # The slug must be set to nil for the friendly_id to update on title change
      @course.slug = nil if @course.title != params[:course][:title]

      @course.update_pub_date(params[:course][:pub_status]) if params[:course][:pub_status] != @course.pub_status

      if course_params[:category_id].present? && course_params[:category_id] == "0"
        new_course_params = course_params
      else
        new_course_params = course_params.except(:category_attributes)
      end

      if @course.update(new_course_params)
        OrganizationCourse.where(organization_id: current_user.organization_id, course_id: @course.id).first_or_create do |org_course|
          org_course.organization_id = current_user.organization_id
          org_course.course_id = @course.id
        end
        @course.topics_list(build_topics_list(params))
        case params[:commit]
        when "Save Course"
          redirect_to edit_admin_course_path(@course), notice: "Course was successfully updated."
        when "Save Course and Edit Lessons"
          redirect_to edit_admin_course_lesson_path(@course, @course.lessons.first), notice: "Course was successfully updated."
        else
          redirect_to new_admin_course_lesson_path(@course), notice: "Course was successfully updated."
        end
      else
        @custom = course_params[:category_id] == "0"
        @custom_category = course_params[:category_attributes][:name] if course_params[:category_attributes].present?

        render :edit
      end
    end

    def sort
      params[:order].each do |_k, v|
        Course.find(v[:id]).update_attribute(:course_order, v[:position])
      end

      render nothing: true
    end

    def destroy
      @course.destroy
      redirect_to courses_url, notice: "Course was successfully destroyed."
    end

    private

    def set_category_options
      @category_options = Category.where(organization_id: current_user.organization_id).map do |category|
        [category.name, category.id]
      end

      @category_options << ["Create new category", 0]
    end

    def set_maximums
      @max_title   = Course.validators_on(:title).first.options[:maximum]
      @max_seo     = Course.validators_on(:seo_page_title).first.options[:maximum]
      @max_summary = Course.validators_on(:summary).first.options[:maximum]
      @max_meta    = Course.validators_on(:meta_desc).first.options[:maximum]
    end

    def set_course
      @course = Course.friendly.find(params[:id])
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
        :subsite_course,
        :display_on_dl,
        :subdomain,
        :category_id,
        category_attributes: [:name, :organization_id],
        attachments_attributes: [:course_id, :document, :title, :doc_type, :file_description, :_destroy]
      ]

      params.require(:course).permit(permitted_attributes)
    end

    def build_topics_list(params)
      topics_list = params[:course][:topics] || []
      other_topic = params[:course][:other_topic] == "1" ? [params[:course][:other_topic_text]] : []
      topics_list | other_topic
    end
  end
end
