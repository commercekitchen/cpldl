# frozen_string_literal: true

class AttachmentsController < ApplicationController
  def show
    @attachment = Attachment.find(params[:id])
    authorize @attachment, :show?

    data = AttachmentReader.new(@attachment).read_attachment_data("document")
    
    filename = @attachment.document_file_name

    extension = File.extname(filename)
    file_options = if extension == '.pdf'
                     { disposition: 'inline', type: 'application/pdf', x_sendfile: true }
                   else
                     { disposition: 'attachment', type: ['application/msword',
                                                         'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                                         'application/vnd.openxmlformats-officedocument.presentationml.presentation'],
                       x_sendfile: true }
                   end

    send_data data, file_options.merge({ filename: filename })
  end
end
