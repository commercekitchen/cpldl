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
    # TODO: Do we want to ensure that the assessment was completed to get here?
    # TODO: Yes, we do - the page errors if there's no completed_at date
    @course = Course.friendly.find(params[:course_id])
    authorize @course

    respond_to do |format|
      format.html
      format.pdf do
        @pdf = render_to_string pdf: 'file_name',
               template: pdf_template_path,
               layout: 'pdf.html.erb',
               orientation: 'Landscape',
               page_size: 'Letter',
               show_as_html: params[:debug].present?

        if current_user
          send_data(@pdf,
                    filename: "#{current_user.first_name} #{@course.title} completion certificate.pdf",
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
      "course_completions/show.pdf.erb"
    end
  end

end
