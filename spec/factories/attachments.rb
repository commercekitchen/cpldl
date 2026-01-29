# frozen_string_literal: true

FactoryBot.define do
  factory :attachment do
    doc_type { 'additional-resource' }
    course

    after(:build) do |attachment|
      next if attachment.document_file.attached?

      fixture_path = Rails.root.join('spec', 'fixtures', 'testfile.pdf')
      File.open(fixture_path) do |file|
        attachment.document_file.attach(
          io: file,
          filename: 'testfile.pdf',
          content_type: 'application/pdf'
        )
      end
    end
  end
end
