# frozen_string_literal: true

class CoursePropagationService
  # These are the ONLY scalar attributes copied from master -> imported children.
  # Keep this list small and intentional.
  PROPAGATED_ATTRS = %i[
    title
    seo_page_title
    meta_desc
    summary
    description
    contributor
    language_id
    level
    format
    course_order
    pub_date
  ].freeze

  def initialize(course:)
    @course = course
  end

  # Returns failures: [{ child_id:, error: }, ...]
  def propagate_course_changes!
    failures = []

    child_courses.find_each do |child|
      begin
        Course.transaction(requires_new: true) do
          propagate_course_attributes!(child)
          propagate_topics!(child)
        end
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
        failures << { child_id: child.id, error: e.message }
        Rails.logger.warn(
          "Course propagation failed for child course=#{child.id}: #{e.class}: #{e.message}"
        )
      end
    end

    failures
  end

  private

  def child_courses
    Course.copied_from_course(@course)
  end

  def propagate_course_attributes!(child)
    attrs = @course.attributes.symbolize_keys.slice(*PROPAGATED_ATTRS)

    # If you want child slug to track title changes, uncomment:
    # attrs[:slug] = nil if attrs.key?(:title) && child.respond_to?(:slug=)

    child.update!(attrs)
  end

  # Topics propagation rules:
  # - Always propagate global topics (organization_id nil)
  # - Only map/create org-specific topics into the child org if it accepts custom topics
  #
  # Note: This overwrites child topics every time propagation runs.
  # If you later decide imported courses should own their topics, gate this.
  def propagate_topics!(child)
    parent_topics = @course.topics.to_a
    return if parent_topics.empty?

    global_topics = parent_topics.select { |t| t.organization_id.nil? }
    child_topics = global_topics.dup

    if child.organization.custom_topics?
      parent_org_topics = parent_topics.select { |t| t.organization_id.present? }

      mapped_child_org_topics =
        parent_org_topics.map do |t|
          Topic.find_or_create_by!(
            organization_id: child.organization_id,
            title: t.title.to_s.strip
          )
        end

      # Prefer org-specific topics over global if titles collide
      global_by_title = child_topics.index_by { |t| t.title.to_s.strip.downcase }
      org_by_title    = mapped_child_org_topics.index_by { |t| t.title.to_s.strip.downcase }

      child_topics = global_by_title.merge(org_by_title).values
    end

    child.topics = child_topics
    child.save!
  end
end
