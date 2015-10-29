module Admin
  class LessonsController < BaseController

    before_action :set_course
    before_action :set_maximums, only: [:new, :edit]

    def index

    end

    def show

    end

    def new
      @lesson = Lesson.new
    end

    def edit
      @lesson = @course.lessons.friendly.find(params[:id])
    end

    def create
      @lesson = @course.lessons.build(lesson_params)
      @lesson.lesson_order = 1 # TODO: this isn't finished.
      @lesson.duration = 90 # TODO: this isn't finished.
      if @lesson.save
        redirect_to edit_admin_course_lesson_path(@course, @lesson), notice: "Lesson was successfully created."
      else
        render :new
      end
    end

    def update

    end

    def destroy

    end

    private

    def set_course
      @course = Course.friendly.find(params[:course_id])
    end

    def lesson_params
      params.require(:lesson).permit(:title, :summary, :duration, :story_line,
       :seo_page_title, :meta_desc, :is_assessment, :lesson_order)
    end

    def set_maximums
      @max_title = Lesson.validators_on(:title).first.options[:maximum]
      @max_summary = Lesson.validators_on(:summary).first.options[:maximum]
      @max_seo_page_title = Lesson.validators_on(:seo_page_title).first.options[:maximum]
      @max_meta_desc = Lesson.validators_on(:meta_desc).first.options[:maximum]
    end
  end
end
