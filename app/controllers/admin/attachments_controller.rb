module Admin
  class AttachmentsController < BaseController
    def destroy
      @attachment = Attachment.find(params[:id])
      @attachment.destroy
      redirect_back(fallback_location: root_path)
    end
  end
end
