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
    return [] unless user.admin?

    if record.parent.present?
      [:category_id, :access_level, category_attributes: %i[name organization_id]]
    else
      [:title,
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
       topic_ids: [],
       course_topics_attributes: [topic_attributes: [:title]],
       propagation_org_ids: [],
       category_attributes: %i[name organization_id],
       attachments_attributes: %i[document title doc_type file_description _destroy]]
    end
  end

  class Scope < Scope
    def resolve
      courses = scope.includes(:lessons).where(organization: user.organization)

      if user.is_a? GuestUser
        courses.published.everyone
      elsif user.admin?
        courses.where.not(pub_status: 'A')
      else
        courses.published
      end
    end
  end
end
