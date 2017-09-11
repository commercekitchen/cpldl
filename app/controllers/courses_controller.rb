# == Schema Information
#
# Table name: courses
#
#  id             :integer          not null, primary key
#  title          :string(90)
#  seo_page_title :string(90)
#  meta_desc      :string(156)
#  summary        :string(156)
#  description    :text
#  contributor    :string
#  pub_status     :string           default("D")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :integer
#  level          :string
#  notes          :text
#  slug           :string
#  course_order   :integer
#  pub_date       :datetime
#  format         :string
#  subsite_course :boolean          default(FALSE)
#  parent_id      :integer
#  display_on_dl  :boolean          default(FALSE)
#

class CoursesController < ApplicationController
  before_action :authenticate_user!, only: [:add, :remove, :your, :completed, :bulk_add_courses] if :top_level_domain?
  before_action :authenticate_user!, except: [:index, :show, :start, :complete, :view_attachment, :skills, :designing_courses_1, :designing_courses_2] if :subdomain?

  def index
    result_ids = PgSearch.multisearch(params[:search]).includes(:searchable).map(&:searchable).map(&:id)

    # Only courses are multisearchable right now, so this works
    # If another class is made multisearchable, this won't work as intended
    # PgSearch multisearch isn't working well here - I'm running into
    # an issue similar to https://github.com/rails/rails/issues/13648
    # when I try to chain PgSearch results with AR queries.
    published_results = Course.where(id: result_ids).where(pub_status: "P")

    if user_signed_in? && current_user.profile.language_id
      user_lang_abbrv2 = current_user.profile.language_id == 1 ? "en" : "es"
      language_id = session[:locale] != user_lang_abbrv2 ? find_language_id_by_session : current_user.profile.language_id
      if params[:search].blank?
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: language_id).where_exists(:organization, subdomain: current_organization.subdomain)
      else
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: language_id).where_exists(:organization, subdomain: current_organization.subdomain).merge(published_results)
      end
    else
      @courses = params[:search].blank? ? Course.includes(:lessons).where(pub_status: "P").where_exists(:organization, subdomain: current_organization.subdomain) : Course.includes(:lessons).where(pub_status: "P").where_exists(:organization, subdomain: current_organization.subdomain).merge(published_results)
    end

    @category_ids = current_organization.categories.enabled.map(&:id)
    @disabled_category_ids = current_organization.categories.disabled.map(&:id)
    @disabled_category_courses = @courses.where(category_id: @disabled_category_ids)
    @uncategorized_courses = @courses.where(category_id: nil) + @disabled_category_courses

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @courses }
    end
  end

  def show
    @course = Course.friendly.find(params[:id])

    case @course.pub_status
    when "D"
      flash[:notice] = "That course is not avaliable at this time."
      redirect_to root_path
    when "A"
      flash[:notice] = "That course is no longer avaliable."
      redirect_to root_path
    when "P"
      respond_to do |format|
        format.html do
          # Need to handle the change of course slug, which should 301 redirect.
          if request.path != course_path(@course)
            redirect_to @course, status: :moved_permanently
          else
            render :show
          end
        end
        format.json { render json: @course }
      end
    end
  end

  def add
    @course = Course.friendly.find(params[:course_id])
    course_progress = current_user.course_progresses.where(course_id: @course.id).first_or_create
    course_progress.tracked = true
    if course_progress.save
      redirect_to course_path(@course), notice: "Successfully added this course to your plan."
    else
      render :show, alert: "Sorry, we were unable to add this course to your plan."
    end
  end

  def remove
    @course = Course.friendly.find(params[:course_id])
    course_progress = current_user.course_progresses.where(course_id: @course.id).first_or_create
    course_progress.tracked = false
    if course_progress.save
      redirect_to course_path(@course), notice: "Successfully removed this course to your plan."
    else
      render :show, alert: "Sorry, we were unable to remove this course to your plan."
    end
  end

  def start
    @course = Course.friendly.find(params[:course_id])
    if current_user
      course_progress = current_user.course_progresses.find_or_create_by(course_id: @course.id)
      course_progress.tracked = true
      if course_progress.save
        redirect_to course_lesson_path(@course, course_progress.next_lesson_id)
      else
        render :show, alert: "Sorry, we were unable to add this course to your plan."
      end
    else
      session[:completed_lessons] = []
      redirect_to course_lesson_path(@course, @course.next_lesson_id)
    end
  end

  def complete
    # TODO: Do we want to ensure that the assessment was completed to get here?
    @course = Course.friendly.find(params[:course_id])
    respond_to do |format|
      format.html
      format.pdf do
        @pdf = render_to_string pdf: "file_name",
               template: "courses/complete.pdf.erb",
               layout: "pdf.html.erb",
               orientation: "Landscape",
               page_size: "Letter",
               show_as_html: params[:debug].present?
        if current_user
          send_data(@pdf,
                    filename: "#{current_user.profile.first_name} #{@course.title} completion certificate.pdf",
                    type: "application/pdf")
        else
          send_data(@pdf,
                    filename: "#{@course.title} completion certificate.pdf",
                    type: "application/pdf")
        end
      end
    end
  end

  def your
    tracked_course_ids = current_user.course_progresses.tracked.collect(&:course_id)
    unless params[:search].blank?
      result_ids = PgSearch.multisearch(params[:search]).includes(:searchable).where(searchable_id: tracked_course_ids).map(&:searchable).map(&:id)
      @results = Course.where(id: result_ids)
    end

    @courses = params[:search].blank? ? Course.where(id: tracked_course_ids) : @results
    @skip_quiz = current_user.profile.opt_out_of_recommendations

    @category_ids = current_organization.categories.enabled.map(&:id)
    @disabled_category_ids = current_organization.categories.disabled.map(&:id)
    @disabled_category_courses = @courses.where(category_id: @disabled_category_ids)
    @uncategorized_courses = @courses.where(category_id: nil) + @disabled_category_courses

    respond_to do |format|
      format.html { render :your }
      format.json { render json: @courses }
    end
  end

  def completed
    completed_ids = current_user.course_progresses.completed.collect(&:course_id)
    @courses = Course.where(id: completed_ids)

    respond_to do |format|
      format.html { render "completed_list", layout: "user/logged_in_with_sidebar" }
      format.json { render json: @courses }
    end
  end

  def view_attachment
    @course = Course.friendly.find(params[:course_id])
    extension = File.extname(@course.attachments.find(params[:attachment_id]).document_file_name)
    if extension == ".pdf"
      file_options = { disposition: "inline", type: "application/pdf", x_sendfile: true }
    else
      file_options = { disposition: "attachment", type: ["application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"],
        x_sendfile: true }
    end
    send_file @course.attachments.find(params[:attachment_id]).document.path, file_options
  end

  def quiz
  end

  def quiz_submit
    current_user.update!(quiz_responses_object: quiz_params.to_h) unless current_user.quiz_responses_object.present?
    recommendation_service = CourseRecommendationService.new(current_organization.id, quiz_params)
    recommendation_service.add_recommended_courses(current_user.id)
    redirect_to your_courses_path
  end

  def skills
    @course = Course.friendly.find(params[:course_id])
  end

  def designing_courses_1
  end

  def designing_courses_2
  end

  private

  def find_language_id_by_session
    case session[:locale]
    when "en"
      1
    when "es"
      2
    end
  end

  def quiz_params
    params.permit("set_one", "set_two", "set_three")
  end
end
