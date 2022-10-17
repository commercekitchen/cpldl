# frozen_string_literal: true

module Admin
  class AttachmentsController < BaseController
    def destroy
      @attachment = Attachment.find(params[:id])
      authorize @attachment
      @attachment.destroy
      redirect_to edit_admin_course_path(@attachment.course)
    end

    def sort
      authorized_courses = policy_scope(Course)
      attachments = Attachment.where(course: authorized_courses)
      SortService.sort(model: attachments, order_params: params[:order], attribute_key: :attachment_order, user: current_user)

      head :ok
    rescue ActiveRecord::RecordNotFound
      raise Pundit::NotAuthorizedError
    end
  end
end
