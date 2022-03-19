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
      [:category_id,
       :access_level,
       :pub_status,
       :notes,
       :survey_url,
       category_attributes: %i[name organization_id],
       attachments_attributes: %i[document title doc_type file_description _destroy]]
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
       :survey_url,
       topic_ids: [],
       course_topics_attributes: [topic_attributes: [:title]],
       category_attributes: %i[name organization_id],
       attachments_attributes: %i[document title doc_type file_description _destroy]]
    end
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
