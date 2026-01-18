# frozen_string_literal: true

module Ckeditor
  class Picture < Ckeditor::Asset
    validates :data_file, presence: true
    validate :data_file_must_be_image

    # TODO: Remove after migration
    has_attached_file :data, Rails.configuration.ckeditor_paperclip_picture_opts

    def data_file_must_be_image
      return unless data_file.attached?
      ct = data_file.blob.content_type
      errors.add(:data_file, "must be an image") unless ct&.start_with?("image/")
    end

    def url_content
      return nil unless data_file.attached?
      Rails.application.routes.url_helpers.rails_representation_path(variant_content.processed, only_path: true)
    end

    def url_thumb
      return nil unless data_file.attached?
      Rails.application.routes.url_helpers.rails_representation_path(variant_thumb.processed, only_path: true)
    end

    def variant_content
      data_file.variant(resize_to_limit: [800, nil])
    end

    def variant_thumb
      data_file.variant(resize_to_fill: [118, 100])
    end
  end
end
