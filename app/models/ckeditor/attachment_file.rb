# frozen_string_literal: true

module Ckeditor
  class AttachmentFile < Ckeditor::Asset
    validates :data_file, presence: true

    # TODO: Remove after migration
    has_attached_file :data, Rails.configuration.ckeditor_paperclip_opts

    def url
      return nil unless data_file.attached?
      Rails.application.routes.url_helpers.rails_blob_path(data_file, only_path: true)
    end
  end
end

