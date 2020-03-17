# frozen_string_literal: true

module Admin
  class AttachmentsController < BaseController
    def destroy
      @attachment = Attachment.find(params[:id])
      authorize @attachment
      @attachment.destroy
      redirect_to edit_admin_course_path(@attachment.course)
    end
  end
end
