class Administrators::AttachmentsController < Administrators::BaseController
  before_action :set_attachment, only: [:show, :edit, :update, :destroy]

  # GET /attachments
  def index
    @attachments = Attachment.all
  end

  # GET /attachments/1
  def show
  end

  # GET /attachments/new
  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(attachment_params)
  end

  def update
    @attachment = Attachment.find(params[:id])
    @attachment.update(attachment_params)
  end

  # DELETE /attachments/1
  def destroy
    @attachment.destroy
    redirect_to attachments_url, notice: "Attachment was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_attachment
    @attachment = Attachment.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def attachment_params
    params.require(:attachment).permit(:course_id, :title, :document, :doc_type)
  end

end
