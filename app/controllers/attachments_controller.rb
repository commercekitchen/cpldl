class AttachmentsController < ApplicationController
  before_action :set_attachment, only: [:show, :edit, :update, :destroy]

  # GET /attachments/new
  def new
    @attachment = Attachment.new
  end

  # POST /attachments
  def create
    @attachment = Attachment.new(attachment_params)
  end

  def update
    @attachment = Attachment.find(params[:id])
    @attachment.update(attachment_params)
  end

  private

    # Only allow a trusted parameter "white list" through.
    def attachment_params
      params.require(:attachment).permit(:course_id, :title, :document, :doc_type)
    end
end
