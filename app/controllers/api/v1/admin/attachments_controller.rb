# frozen_string_literal: true

module Api
  module V1
    module Admin
      class AttachmentsController < ::Api::V1::BaseController
        before_action :require_admin
        before_action :set_course

        def create
          authorize @course, :update?
          attachment = @course.attachments.build(attachment_params)

          if attachment.save
            render json: attachment_payload(attachment), status: :created
          else
            render status: :unprocessable_entity, json: { errors: attachment.errors.full_messages }
          end
        end

        def destroy
          authorize @course, :update?
          attachment = @course.attachments.find(params[:id])
          attachment.destroy!
          head :no_content
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def set_course
          @course = current_organization.courses.find(params[:course_id])
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

        def attachment_params
          params.require(:attachment).permit(:document_file, :title, :doc_type, :file_description)
        end
      end
    end
  end
end
