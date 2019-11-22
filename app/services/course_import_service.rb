# frozen_string_literal: true

class CourseImportService
  def initialize(organization:, course_id:)
    @organization = organization
    @parent_course = Course.find(course_id)
  end

  def import!
    ActiveRecord::Base.transaction do
      @new_course = @parent_course.dup
      @new_course.parent_id = @parent_course.id
      @new_course.subsite_course = false
      @new_course.pub_date = nil
      @new_course.pub_status = 'D'
      @new_course.category_id = new_or_existing_subsite_category_id(@parent_course.category)
      @new_course.organization = @organization
      @new_course.save!

      # Create copies of the lessons and ASLs
      @parent_course.lessons.each do |imported_lesson|
        new_lesson = imported_lesson.dup
        new_lesson.parent_id = imported_lesson.id
        new_lesson.course_id = @new_course.id
        new_lesson.story_line = nil
        new_lesson.story_line = imported_lesson.story_line
        new_lesson.save!
      end

      # Create copies of the attachments
      @parent_course.attachments.each do |attachment|
        new_attachment = attachment.dup
        new_attachment.document = attachment.document
        new_attachment.course_id = @new_course.id
        new_attachment.save!
      end

      # Create copies of the topics
      @parent_course.course_topics.each do |course_topic|
        new_topic = course_topic.dup
        new_topic.course_id = @new_course.id
        new_topic.save!
      end
    end

    @new_course
  end

  private

  def new_or_existing_subsite_category_id(category)
    return nil if category.blank?

    @organization.categories.each do |org_category|
      if org_category.name.downcase == category.name.downcase
        @subsite_category_id = org_category.id
      end
    end

    @subsite_category_id || @organization.categories.create(name: category.name).id
  end
end
