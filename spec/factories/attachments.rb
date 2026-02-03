# frozen_string_literal: true

require 'stringio'

FactoryBot.define do
  factory :attachment do
    doc_type { 'additional-resource' }
    course

    trait :with_document_file do
      after(:build) do |attachment|
        next if attachment.document_file.attached?

        fixture_path = Rails.root.join('spec', 'fixtures', 'testfile.pdf')
        attachment.document_file.attach(
          io: StringIO.new(File.binread(fixture_path)),
          filename: 'testfile.pdf',
          content_type: 'application/pdf'
        )
      end
    end
  end
end
