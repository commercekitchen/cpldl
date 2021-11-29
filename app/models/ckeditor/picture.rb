# frozen_string_literal: true

module Ckeditor
  class Picture < Ckeditor::Asset
    has_attached_file :data, Rails.configuration.ckeditor_paperclip_picture_opts

    validates_attachment_presence :data
    validates_attachment_size :data, less_than: 2.megabytes
    validates_attachment_content_type :data, content_type: /\Aimage/

    def url_content
      url(:content)
    end
  end
end
