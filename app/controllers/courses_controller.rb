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
#

class CoursesController < ApplicationController

  # before_action :authenticate_user!, only: [:your, :completed, :start]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    results  = PgSearch.multisearch(params[:search]).includes(:searchable).map(&:searchable)
    @courses = params[:search].blank? ? Course.includes(:lessons).where(pub_status: "P") : results

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @courses }
    end
  end

  def show
    @course = Course.friendly.find(params[:id])
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
    course_progress = current_user.course_progresses.find_or_create_by(course_id: @course.id)
    course_progress.tracked = true
    if course_progress.save
      redirect_to course_lesson_path(@course, course_progress.next_lesson_id)
    else
      render :show, alert: "Sorry, we were unable to add this course to your plan."
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
        send_data(@pdf,
                  filename: "#{current_user.profile.first_name} #{@course.title} completion certificate.pdf",
                  type: "application/pdf")
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
    pdf_options = { disposition: "inline", type: "application/pdf", x_sendfile: true }
    send_file @course.attachments.find(params[:attachment_id]).document.path, pdf_options
  end

  def quiz
  end

  def quiz_submit
    # Finds and bulk adds relevant core desktop topics
    case params["set_one"]
    when "1"
      bulk_add_courses(Course.topic_search("Core").where(format: "D", level: "Beginner", pub_status: "P"))
    when "2"
      bulk_add_courses(Course.topic_search("Core").where(format: "D", level: "Intermediate", pub_status: "P"))
    end

    # Finds and bulk adds relevant core mobile topics
    case params["set_two"]
    when "1"
      bulk_add_courses(Course.topic_search("Core").where(format: "M", level: "Beginner", pub_status: "P"))
    when "2"
      bulk_add_courses(Course.topic_search("Core").where(format: "M", level: "Intermediate", pub_status: "P"))
    end

    # Finds and bulk adds topic_specific courses
    set_three_topics = { 1 => "Information Searching",
                         2 => "Communication Social Media",
                         3 => "Productivity",
                         4 => "Job Search",
                         5 => "Software Apps" }

    bulk_add_courses(Course.topic_search(set_three_topics[params["set_three"].to_i]).where(pub_status: "P"))

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
end
