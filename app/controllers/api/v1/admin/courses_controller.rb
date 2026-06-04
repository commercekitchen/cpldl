# frozen_string_literal: true

module Api
  module V1
    module Admin
      class CoursesController < ::Api::V1::BaseController
        before_action :require_admin

        def index
          courses = current_organization.courses.includes(:category, :topics, :language)
          render json: { courses: courses.map { |c| course_payload(c) } }
        end

        def show
          course = current_organization.courses
                                       .includes(:category, :topics, :language, :resource_links,
                                                 attachments: { document_file_attachment: :blob })
                                       .find(params[:id])
          authorize course, :update?
          render json: { course: course_detail_payload(course), options: form_options }
        end

        def new_form_options
          authorize Course.new(organization: current_organization), :create?
          render json: { options: form_options }
        end

        def create
          course = current_organization.courses.new
          authorize course
          permitted = standard_course_params
          inject_category_org!(permitted)
          course.assign_attributes(permitted)

          if course.save
            course.reload
            render status: :created, json: { course: course_detail_payload(course), options: form_options }
          else
            render status: :unprocessable_entity, json: { errors: course.errors.full_messages }
          end
        end

        def update
          course = current_organization.courses
                                       .includes(:category, :topics, :language, :resource_links,
                                                 attachments: { document_file_attachment: :blob })
                                       .find(params[:id])
          authorize course, :update?

          permitted = course.imported_course? ? imported_course_params : standard_course_params
          inject_category_org!(permitted)
          course.update!(permitted)

          render json: { course: course_detail_payload(course.reload), options: form_options }
        rescue ActiveRecord::RecordInvalid => e
          render status: :unprocessable_entity, json: { errors: e.record.errors.full_messages }
        end

        def pub_status
          course = current_organization.courses.find(params[:id])
          authorize course, :update?

          unless Course.pub_status_options.map(&:last).include?(params[:pub_status])
            render status: :unprocessable_entity, json: { message: 'Invalid publication status.' }
            return
          end

          course.update!(pub_status: params[:pub_status])
          render json: { pubStatus: course.pub_status }
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def course_payload(course)
          {
            id: course.id,
            title: course.title,
            category: course.category&.name,
            topics: course.topics.map(&:title),
            language: course.language&.name,
            imported: course.imported_course?,
            pubStatus: course.pub_status
          }
        end

        def course_detail_payload(course)
          {
            id: course.id,
            title: course.title,
            contributor: course.contributor,
            summary: course.summary,
            description: course.description,
            notes: course.notes,
            languageId: course.language_id,
            language: course.language&.name,
            format: course.format,
            level: course.level,
            accessLevel: course.access_level,
            seoPageTitle: course.seo_page_title,
            metaDesc: course.meta_desc,
            pubStatus: course.pub_status,
            attCourse: course.new_course,
            surveyUrl: course.survey_url,
            categoryId: course.category_id,
            category: course.category&.name,
            topicIds: course.topics.map(&:id),
            imported: course.imported_course?,
            topicsEditable: !course.imported_course? || current_organization.custom_topics?,
            resourceLinks: course.resource_links.map { |rl| { id: rl.id, label: rl.label, url: rl.url } },
            attachments: course.attachments.map { |a| attachment_payload(a) }
          }
        end

        def attachment_payload(attachment)
          url = attachment.document_file.attached? ? rails_blob_path(attachment.document_file, only_path: true) : nil
          {
            id: attachment.id,
            title: attachment.title,
            docType: attachment.doc_type,
            fileDescription: attachment.file_description,
            filename: attachment.document_file.attached? ? attachment.document_file.filename.to_s : nil,
            url: url
          }
        end

        def form_options
          {
            languages: Language.all.map { |l| { id: l.id, name: l.name } },
            categories: current_organization.categories.map { |c| { id: c.id, name: c.name } },
            topics: Topic.for_organization(current_organization).map { |t| { id: t.id, name: t.title } }
          }
        end

        def inject_category_org!(permitted)
          return if permitted[:category_attributes].blank?

          permitted[:category_attributes][:organization_id] = current_organization.id
        end

        def standard_course_params
          params.require(:course).permit(
            :title, :contributor, :summary, :description, :notes,
            :language_id, :format, :level, :access_level,
            :seo_page_title, :meta_desc, :pub_status,
            :new_course, :survey_url, :category_id,
            topic_ids: [],
            category_attributes: %i[name organization_id],
            resource_links_attributes: %i[id label url _destroy]
          )
        end

        def imported_course_params
          base = params.require(:course).permit(
            :access_level, :pub_status, :notes, :survey_url, :category_id,
            category_attributes: %i[name organization_id],
            resource_links_attributes: %i[id label url _destroy]
          )

          if current_organization.custom_topics?
            base.merge(params.require(:course).permit(topic_ids: []))
          else
            base
          end
        end
      end
    end
  end
end
