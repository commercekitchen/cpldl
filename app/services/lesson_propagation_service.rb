# frozen_string_literal: true

class LessonPropagationService
  COPYABLE_ATTRS = %w[
    lesson_order
    title
    duration
    summary
    seo_page_title
    meta_desc
    is_assessment
  ].freeze

  def initialize(lesson:)
    @lesson = lesson
  end

  def add_to_course!(course)
    new_lesson = @lesson.dup

    new_lesson.parent_id = @lesson.id
    new_lesson.course_id = course.id

    # Ensure child does not carry its own storyline zip (inherit from parent)
    new_lesson.story_line = nil if new_lesson.respond_to?(:story_line) # Paperclip during migration

    new_lesson.save!

    # ActiveStorage: ensure no zip was somehow attached
    new_lesson.story_line_archive.detach if new_lesson.respond_to?(:story_line_archive) && new_lesson.story_line_archive.attached?

    # Do NOT copy unzip status/error fields to child
    clear_storyline_tracking!(new_lesson)

    new_lesson
  end

  def update_children!
    attrs = @lesson.attributes.slice(*COPYABLE_ATTRS)

    Lesson.copied_from_lesson(@lesson).find_each do |child|
      child.update!(attrs)

      # Enforce invariant: children never store their own storyline zip
      child.story_line_archive.detach if child.respond_to?(:story_line_archive) && child.story_line_archive.attached?

      # Do not propagate parent’s unzip status/errors to children
      clear_storyline_tracking!(child)
    end
  end

  private

  def clear_storyline_tracking!(lesson)
    lesson.update_columns(storyline_unzip_status: nil, storyline_unzip_error: nil, storyline_unzip_failed_at: nil)
  end
end
