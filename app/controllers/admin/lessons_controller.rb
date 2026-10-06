# frozen_string_literal: true

module Admin
  class LessonsController < BaseController

    before_action :set_course, except: [:sort]

    def new
      @course_lessons = Lesson.where(course: @course)
      @lesson = @course.lessons.new
      authorize @lesson
    end

    def edit
      @lesson = @course.lessons.friendly.find(params[:id])
      authorize @lesson
    end

    def create
      @lesson = @course.lessons.build(lesson_params)
      authorize @lesson

      @lesson.duration_to_int(lesson_params[:duration])
      @lesson.lesson_order = @course.lessons.count + 1

      if @lesson.save
        @lesson.enqueue_storyline_unzip if lesson_params[:story_line_archive].present?
        add_lesson_to_child_courses!
        redirect_to edit_admin_course_lesson_path(@course, @lesson), notice: 'Lesson was successfully created.'
      else
        render :new
      end
    end

    def update
      @lesson ||= @course.lessons.friendly.find(params[:id])
      authorize @lesson

      # set slug to nil to regenerate if title changes
      @lesson.slug = nil if @lesson.title != params[:lesson][:title]
      @lesson_params = lesson_params
      @lesson_params[:duration] = @lesson.duration_to_int(lesson_params[:duration])

      archive_uploaded = lesson_params[:story_line_archive].present?

      if @lesson.update(@lesson_params)
        @lesson.enqueue_storyline_unzip if archive_uploaded
        LessonPropagationService.new(lesson: @lesson).update_children!
        success_message = 'Lesson successfully updated.'
        redirect_to edit_admin_course_lesson_path, notice: success_message
      else
        render :edit, notice: 'Lesson failed to update.'
      end
    end

    def destroy_asl_attachment
      @lesson = @course.lessons.friendly.find(params[:lesson_id])
      authorize @lesson, :update?

      @lesson.story_line_archive.purge if @lesson.story_line_archive.attached?

      flash[:notice] = 'Story Line successfully removed, please upload a new story line .zip file.'
      render :edit
    end

    def sort
      lessons = policy_scope(Lesson)
      SortService.sort(model: lessons, order_params: params[:order], attribute_key: :lesson_order, user: current_user)

      lessons.each do |lesson|
        LessonPropagationService.new(lesson: lesson).update_children!
      end

      head :ok
    end

    private

    def set_course
      @course = Course.friendly.find(params[:course_id])
    end

    def lesson_params
      params.require(:lesson).permit(:title,
                                     :summary,
                                     :duration,
                                     :story_line_archive,
                                     :seo_page_title,
                                     :meta_desc,
                                     :lesson_order,
                                     :subdomain)
    end

    def add_lesson_to_child_courses!
      courses = Course.copied_from_course(@lesson.course)

      courses.each do |course|
        LessonPropagationService.new(lesson: @lesson).add_to_course!(course)
      end
    end
  end
end
