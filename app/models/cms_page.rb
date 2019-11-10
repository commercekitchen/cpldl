# frozen_string_literal: true

class CmsPage < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[slugged history]

  def slug_candidates
    [
      :title,
      %i[title subdomain_for_slug]
    ]
  end

  def subdomain_for_slug
    subdomain
  end

  attr_accessor :subdomain

  belongs_to :language
  belongs_to :organization

  validates :title, length: { maximum: 90 }, presence: true,
    uniqueness: { scope: :organization_id, message: 'has already been taken for the organization' }
  validates :body, presence: true
  validates :language_id, numericality: true, allow_nil: true
  validates :seo_page_title, length: { maximum: 90 }
  validates :meta_desc, length: { maximum: 156 }
  validates :author, presence: true
  validates :pub_status, presence: true,
    inclusion: { in: %w[P D A], message: '%<value>s is not a valid status', allow_nil: true, allow_blank: true }
  validates :audience, presence: true,
    inclusion: { in: %w[Unauth Auth Admin All], message: '%<value>s is not a valid audience', allow_nil: true, allow_blank: true }

  default_scope { order('cms_page_order ASC') }

  def current_pub_status
    case pub_status
    when 'D' then 'Draft'
    when 'P' then 'Published'
    when 'A' then 'Archived'
    end
  end

  def set_pub_date
    self.pub_date = Time.zone.now unless pub_status != 'P'
  end

  def update_pub_date(new_pub_status)
    self.pub_date = if new_pub_status == 'P'
                      Time.zone.now
                    end
  end
end
