# frozen_string_literal: true

class CoursePolicy < AdminOnlyPolicy
  def show?
    return false unless record.organization == user.organization
    return false unless record.published?

    if user.is_a?(GuestUser)
      record.everyone?
    else
      true
    end
  end

  def track?
    return false if user.is_a?(GuestUser)

    record.organization == user.organization && record.published?
  end

  def preview?
    return false unless user.admin?

    record.organization == Organization.pla
  end

  def permitted_attributes
    record.imported_course? ? imported_course_attributes : standard_course_attributes
  end

  private

  def imported_course_attributes
    attrs = [
      :category_id,
      :access_level,
      :pub_status,
      :notes,
      :survey_url,
      category_attributes: %i[name organization_id],
      attachments_attributes: %i[document_file title doc_type file_description _destroy],
      resource_links_attributes: %i[id label url _destroy]
    ]

    if record.organization.custom_topics?
      attrs << { topic_ids: [] } # can also be :topic_ids, topic_ids: [] depending on style
      # Better: keep it consistent with the “strong params style”:
      attrs << { course_topics_attributes: [topic_attributes: %i[title organization_id]] }
    end

    # If you want *exactly* your prior style, do:
    # attrs << :topic_ids
    # attrs << { course_topics_attributes: [topic_attributes: %i[title organization_id]] }
    # BUT: :topic_ids alone does NOT permit arrays. You need topic_ids: [] somewhere.
    attrs
  end

  def standard_course_attributes
    [
      :title,
      :seo_page_title,
      :meta_desc,
      :summary,
      :description,
      :contributor,
      :pub_status,
      :language_id,
      :level,
      :notes,
      :delete_document,
      :course_order,
      :pub_date,
      :format,
      :access_level,
      :category_id,
      :survey_url,
      :new_course,
      topic_ids: [],
      course_topics_attributes: [topic_attributes: [:title]],
      category_attributes: %i[name organization_id],
      attachments_attributes: %i[document_file title doc_type file_description _destroy],
      resource_links_attributes: %i[id label url _destroy]
    ]
  end

  class Scope < Scope
    def resolve
      courses = scope.includes(:lessons).where(organization: user.organization)

      if user.is_a? GuestUser
        courses.visible_to_users.everyone
      elsif user.admin?
        courses.where.not(pub_status: 'A')
      else
        courses.visible_to_users
      end
    end
  end
end
