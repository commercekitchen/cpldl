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

      if @lesson.is_assessment?
        validate_assessment || return
      end

      if @lesson.save
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

      if @lesson.update(@lesson_params)
        LessonPropagationService.new(lesson: @lesson).update_children!
        success_message = 'Lesson successfully updated.'
        redirect_to edit_admin_course_lesson_path, notice: success_message
      else
        render :edit, notice: 'Lesson failed to update.'
      end
    end

    def destroy_asl_attachment
      @lesson = @course.lessons.friendly.find(params[:format])
      authorize @lesson, :update?

      @lesson.story_line = nil
      @lesson.save
      FileUtils.remove_dir "#{Rails.root}/public/storylines/#{@lesson.id}", true
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
                                     :story_line,
                                     :seo_page_title,
                                     :meta_desc,
                                     :is_assessment,
                                     :lesson_order,
                                     :subdomain)
    end

    def validate_assessment
      if @course.lessons.where(is_assessment: true).blank?
        @lesson.lesson_order = @lesson.course.lessons.count + 1
        true
      else
        warnings = ['There can only be one assessment for a Course.',
                    'If you are sure you want to replace it, please delete the existing one and try again.',
                    'Otherwise, please edit the existing assessment for this course.']
        flash.now[:alert] = warnings
        render :new and return # rubocop:disable Style/AndOr
      end
    end

    def add_lesson_to_child_courses!
      courses = Course.copied_from_course(@lesson.course)

      courses.each do |course|
        LessonPropagationService.new(lesson: @lesson).add_to_course!(course)
      end
    end
  end
end
