# frozen_string_literal: true

class AttachmentsController < ApplicationController
  def show
    @attachment = Attachment.find(params[:id])
    authorize @attachment, :show?

    extension = File.extname(@attachment.document_file_name)
    file_options = if extension == '.pdf'
                     { disposition: 'inline', type: 'application/pdf', x_sendfile: true }
                   else
                     { disposition: 'attachment', type: ['application/msword',
                                                         'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                                         'application/vnd.openxmlformats-officedocument.presentationml.presentation'],
                       x_sendfile: true }
                   end
    send_file @attachment.document.path, file_options
  end
end
