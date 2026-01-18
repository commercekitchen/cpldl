class AttachmentsController < ApplicationController
  def show
    @attachment = Attachment.find(params[:id])
    authorize @attachment, :show?

    if @attachment.document_file.attached?
      filename = @attachment.document_file.blob.filename.to_s
      disposition = filename.downcase.end_with?(".pdf") ? "inline" : "attachment"
      return redirect_to rails_blob_path(@attachment.document_file, disposition: disposition)
    end

    data = AttachmentReader.new(@attachment).read_attachment_data("document")
    filename = @attachment.document_file_name.to_s

    extension = File.extname(filename).downcase
    file_options =
      if extension == ".pdf"
        { disposition: "inline", type: "application/pdf", x_sendfile: true }
      else
        { disposition: "attachment", x_sendfile: true }
      end

    send_data data, file_options.merge(filename: filename)
  end
end
