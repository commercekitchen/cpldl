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
  before_action :authenticate_user!, except: [:index, :show, :start, :complete, :view_attachment] if :subdomain?

  def index
    results = PgSearch.multisearch(params[:search]).includes(:searchable).map(&:searchable)
    published_results = []

    results.each do |result|
      published_results << result if result.pub_status == "P"
    end

    if user_signed_in? && current_user.profile.language_id
      user_lang_abbrv2 = current_user.profile.language_id == 1 ? "en" : "es"
      language_id = session[:locale] != user_lang_abbrv2 ? find_language_id_by_session : current_user.profile.language_id
      if params[:search].blank?
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: language_id).where_exists(:organization, subdomain: current_organization.subdomain)
      else
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: language_id).where_exists(:organization, subdomain: current_organization.subdomain) & published_results
      end
    else
      @courses = params[:search].blank? ? Course.includes(:lessons).where(pub_status: "P").where_exists(:organization, subdomain: current_organization.subdomain) : Course.includes(:lessons).where(pub_status: "P").where_exists(:organization, subdomain: current_organization.subdomain) & published_results
    end

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
      @results = PgSearch.multisearch(params[:search]).includes(:searchable).where(id: tracked_course_ids).map(&:searchable)
    end

    @courses = params[:search].blank? ? Course.where(id: tracked_course_ids) : @results
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
      file_options = { disposition: "attachment", type: [ "application/msword",
                                                  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                                                  "application/vnd.openxmlformats-officedocument.presentationml.presentation"],
                      x_sendfile: true}
    end
    send_file @course.attachments.find(params[:attachment_id]).document.path, file_options
  end

  def quiz
  end

  def quiz_submit
    case I18n.locale
    when :es
      @org_courses = Course.where_exists(:organization_course, organization_id: current_organization.id).where(language_id: Language.find_by_name("Spanish").id)
    when :en
      @org_courses = Course.where_exists(:organization_course, organization_id: current_organization.id).where(language_id: Language.find_by_name("English").id)
    end
    # Finds and bulk adds relevant core desktop topics
    case params["set_one"]
    when "1"
      bulk_add_courses(Course.topic_search("Core").where(format: "D", level: "Beginner", pub_status: "P") & @org_courses)
    when "2"
      bulk_add_courses(Course.topic_search("Core").where(format: "D", level: "Intermediate", pub_status: "P") & @org_courses)
    end

    # Finds and bulk adds relevant core mobile topics
    case params["set_two"]
    when "1"
      bulk_add_courses(Course.topic_search("Core").where(format: "M", level: "Beginner", pub_status: "P") & @org_courses)
    when "2"
      bulk_add_courses(Course.topic_search("Core").where(format: "M", level: "Intermediate", pub_status: "P") & @org_courses)
    end

    # Finds and bulk adds topic_specific courses
    set_three_topics = { 1 => "Information Searching",
                         2 => "Communication Social Media",
                         3 => "Productivity",
                         4 => "Job Search",
                         5 => "Software Apps",
                         6 => "Security" }

    bulk_add_courses(Course.topic_search(set_three_topics[params["set_three"].to_i]).where(pub_status: "P") & @org_courses)

    # Send them back to "My Courses" page
    redirect_to your_courses_path
  end

  def bulk_add_courses(course_collection)
    course_collection.each do |course|
      course_progress = current_user.course_progresses.where(course_id: course.id).first_or_create
      course_progress.tracked = true
      course_progress.save
    end
  end

  def skills
    @course = Course.friendly.find(params[:course_id])
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
end
