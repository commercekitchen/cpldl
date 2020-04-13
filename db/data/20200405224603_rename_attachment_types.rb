# frozen_string_literal: true

class RenameAttachmentTypes < ActiveRecord::Migration[5.2]
  def up
    Attachment.where(doc_type: 'post-course').each do |a|
      a.update!(doc_type: 'additional-resource')
    end

    Attachment.where(doc_type: 'supplemental').each do |a|
      a.update!(doc_type: 'text-copy')
    end
  end

  def down
    Attachment.where(doc_type: 'additional-resource').each do |a|
      a.update!(doc_type: 'post-course')
    end

    Attachment.where(doc_type: 'text-copy').each do |a|
      a.update!(doc_type: 'supplemental')
    end

  end
end
