# frozen_string_literal: true

FactoryBot.define do
  factory :attachment do
    document_file_name 'additional-resource-info.pdf'
    document_content_type 'application/pdf'
    document_file_size 22
    document_updated_at '2015-10-10 20:00:00'
    course
  end
end
