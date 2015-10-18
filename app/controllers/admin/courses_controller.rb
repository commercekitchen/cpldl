module Admin
  class CoursesController < BaseController

    before_action :set_course, only: [:show, :edit, :update, :destroy]
    before_action :set_maximums, only: [:new, :edit]

    def index
      @courses = Course.all
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
        @course.topics_list(params[:course][:topics])
        redirect_to @course, notice: "Course was successfully created."
      else
        render :new
      end
    end

    def update
      if @course.update(course_params)
        @course.topics_list(params[:course][:topics])
        redirect_to @course, notice: "Course was successfully updated."
      else
        render :edit
      end
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
      params.require(:course).permit(:title, :seo_page_title, :meta_desc, :summary, :description, :contributor, :pub_status,
        :language_id, :level, :topics, :notes, :delete_document,
        attachments_attributes: [:course_id, :document, :title, :doc_type, :_destroy])
    end
  end
end
