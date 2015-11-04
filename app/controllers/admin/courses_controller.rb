module Admin
  class CoursesController < BaseController

    before_action :set_course, only: [:show, :edit, :update, :destroy]
    before_action :set_maximums, only: [:new, :edit]

    def index
      @courses = Course.includes(:language).all
      render layout: "admin/base_with_sidebar"
    end

    def show
      render "courses/show"
    end

    def new
      @course = Course.new
    end

    def edit

    end

    def create
      @course = Course.new(course_params)

      if @course.save
        @course.topics_list(build_topics_list(params))
        if params[:commit] == "Save Course"
          redirect_to edit_admin_course_path(@course), notice: "Course was successfully created."
        else
          redirect_to new_admin_course_lesson_path(@course), notice: "Course was successfully created. Now add some lessons."
        end
      else
        render :new
      end
    end

    def update
      @course.slug = nil # The slug must be set to nil for the friendly_id to update
      if @course.update(course_params)
        @course.topics_list(build_topics_list(params))
        if params[:commit] == "Save Course"
          redirect_to edit_admin_course_path(@course), notice: "Course was successfully updated."
        else
          redirect_to new_admin_course_lesson_path(@course), notice: "Course was successfully updated."
        end
      else
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
      params.require(:course).permit(:title,
                                     :seo_page_title,
                                     :meta_desc, :summary,
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
            attachments_attributes: [:course_id,
                                     :document,
                                     :title,
                                     :doc_type,
                                     :_destroy])
    end

    def build_topics_list(params)
      topics_list = params[:course][:topics] || []
      other_topic = params[:course][:other_topic] == "1" ? [params[:course][:other_topic_text]] : []
      topics_list | other_topic
    end
  end
end
