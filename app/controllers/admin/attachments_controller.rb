module Admin
  class AttachmentsController < BaseController
    def destroy
      @attachment = Attachment.find(params[:id])
      @attachment.destroy
      redirect_to :back
    end

    private

    def attachment_params
      params.require(:attachment).permit(:course_id,
                                         :document,
                                         :title,
                                         :doc_type,
                                         :_destroy)
    end
  end
end
