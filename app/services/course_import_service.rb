# frozen_string_literal: true

class CourseImportService
  def initialize(organization:, course_id:)
    @organization = organization
    @parent_course = Course.find(course_id)
    @new_course = @parent_course.dup
  end

  def import!
    ActiveRecord::Base.transaction do
      save_new_course!
      copy_parent_lessons!
      copy_topics!
      copy_attachments!
    end

    @new_course
  end

  private

  def save_new_course!
    @new_course.parent_id = @parent_course.id
    @new_course.pub_date = nil
    @new_course.pub_status = 'D'
    @new_course.category_id = new_or_existing_subsite_category_id(@parent_course.category)
    @new_course.organization = @organization
    @new_course.save!
  end

  def new_or_existing_subsite_category_id(category)
    return nil if category.blank?

    @organization.categories.each do |org_category|
      if org_category.name.downcase == category.name.downcase
        @subsite_category_id = org_category.id
      end
    end

    @subsite_category_id || @organization.categories.create(name: category.name).id
  end

  def copy_parent_lessons!
    @parent_course.lessons.each do |lesson|
      LessonPropagationService.new(lesson: lesson).add_to_course!(@new_course)
    end
  end

  def copy_topics!
    # Create copies of the topics
    @parent_course.course_topics.each do |course_topic|
      new_topic = course_topic.dup
      new_topic.course_id = @new_course.id
      new_topic.save!
    end
  end

  def copy_attachments!
    # Create copies of the attachments
    @parent_course.additional_resource_attachments.each do |attachment|
      new_attachment = attachment.dup
      new_attachment.document = attachment.document
      new_attachment.course_id = @new_course.id
      new_attachment.save!
    end
  end
end
