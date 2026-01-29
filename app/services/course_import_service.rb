# frozen_string_literal: true

class CourseImportService
  class ImportError < StandardError; end

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
      copy_resource_links!
      copy_attachments!
    end

    @new_course
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    raise ImportError, e.message
  end

  private

  def save_new_course!
    @new_course.parent_id = @parent_course.id
    @new_course.pub_date = nil
    @new_course.pub_status = 'D'
    @new_course.category_id = new_or_existing_subsite_category_id(@parent_course.category)
    @new_course.organization = @organization
    @new_course.survey_url = nil
    @new_course.slug = nil if @new_course.respond_to?(:slug=)
    @new_course.save!
  end

  def new_or_existing_subsite_category_id(category)
    return nil if category.blank?

    existing = @organization.categories.detect do |org_category|
      org_category.name.to_s.casecmp?(category.name.to_s)
    end

    (existing || @organization.categories.create!(name: category.name)).id
  end

  def copy_parent_lessons!
    @parent_course.lessons.each do |lesson|
      LessonPropagationService.new(lesson: lesson).add_to_course!(@new_course)
    end
  end

  def copy_topics!
    @parent_course.course_topics.each do |course_topic|
      new_topic = course_topic.dup
      new_topic.course_id = @new_course.id
      new_topic.save!
    end
  end

  def copy_resource_links!
    @parent_course.resource_links.each do |link|
      new_link = link.dup
      new_link.course_id = @new_course.id
      new_link.save!
    end
  end

  def copy_attachments!
    @parent_course.additional_resource_attachments.each do |attachment|
      unless attachment.respond_to?(:document_file) &&
             attachment.document_file.respond_to?(:attached?) &&
             attachment.document_file.attached?
        raise ImportError,
              "Attachment #{attachment.class}(id=#{attachment.id}) has no ActiveStorage document_file attached"
      end

      new_attachment = attachment.dup
      new_attachment.course_id = @new_course.id

      # Reuse the same blob (recommended: fast + no duplicate storage)
      new_attachment.document_file.attach(attachment.document_file.blob)

      new_attachment.save!
    end
  end
end
