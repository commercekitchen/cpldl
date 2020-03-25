# frozen_string_literal: true

class RemoveChildCourseAttachments < ActiveRecord::Migration[5.2]
  def up
    Course.where.not(parent: nil).each do |course|
      course.attachments.destroy_all
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
