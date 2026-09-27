# frozen_string_literal: true

class CourseCompletionsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def index
    completed_ids = current_user.course_progresses.completed.collect(&:course_id)
    @courses = policy_scope(Course).where(id: completed_ids)

    enable_sidebar('shared/user/sidebar')

    respond_to do |format|
      format.html
      format.json { render json: @courses }
    end
  end

  def show
    @course = Course.friendly.find(params[:course_id])
    authorize @course

    respond_to do |format|
      format.html
      format.pdf do
        @completed_at = resolve_certificate_completed_at
        return head :forbidden unless @completed_at

        @pdf = render_to_string pdf: 'file_name',
               template: pdf_template_path,
               layout: 'pdf.html.erb',
               orientation: 'Landscape',
               page_size: 'Letter',
               show_as_html: params[:debug].present?

        if current_user
          send_data(@pdf,
                    filename: "#{current_user.first_name || current_user.phone_number} #{@course.title} completion certificate.pdf",
                    type: 'application/pdf')
        else
          send_data(@pdf,
                    filename: "#{@course.title} completion certificate.pdf",
                    type: 'application/pdf')
        end
      end
    end
  end

  private

  def pdf_template_path
    if current_organization.custom_certificate_enabled?
      "course_completions/custom_certificates/#{current_organization.subdomain}.pdf.erb"
    else
      'course_completions/show.pdf.erb'
    end
  end

  # CourseProgress#completed_at is stamped as soon as every lesson is complete
  # (see LessonCompletion#update_course_progress), so this is normally already
  # set by the time a signed-in user gets here. The lesson_completions fallback
  # below exists for CourseProgress rows from before that fix - completed in
  # full, but never stamped because completion used to require the assessment
  # lesson specifically. A course_id with no matching progress at all
  # (bots/crawlers guessing course slugs) gets a 403 instead of a certificate.
  def resolve_certificate_completed_at
    return guest_session_completed_at unless current_user

    course_progress = current_user.course_progresses.find_by(course_id: @course.id)
    return course_progress.completed_at if course_progress&.completed_at.present?
    return nil unless course_progress&.all_lessons_completed?

    course_progress.lesson_completions.maximum(:created_at) || Time.zone.now
  end

  # Guests never get a CourseProgress row; their only record of progress is the
  # session-tracked lesson ids set in Api::V1::LessonsController#complete.
  def guest_session_completed_at
    return nil unless @course.all_lessons_completed?(session[:completed_lessons] || [])

    Time.zone.now
  end
end
