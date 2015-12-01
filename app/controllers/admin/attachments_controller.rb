module Admin
  class AttachmentsController < BaseController
    def destroy
      @attachment = Attachment.find(params[:id])
      @attachment.destroy
      redirect_to :back
    end
  end
end