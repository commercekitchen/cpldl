# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  profile_id             :integer
#  quiz_modal_complete    :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  include PgSearch
  # TODO: determine lockable? functionality and add to search
  pg_search_scope :search_users, against: [:email],
                      associated_against: { profile: [:first_name],
                                              roles: [:name] },
                                              using: { tsearch: { prefix: true },
                                                    dmetaphone: { any_word: true },
                                                       trigram: { threshold: 0.1 } }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  rolify
  has_one :profile, dependent: :destroy
  has_many :course_progresses, dependent: :destroy
  accepts_nested_attributes_for :profile
  validates_associated :profile

  def organization_id
    roles.find_by_resource_type("Organization").resource_id
  end

  def organization
    Organization.find(organization_id)
  end

  def tracking_course?(course_id)
    course_progresses.where(course_id: course_id, tracked: true).count > 0
  end

  def completed_lesson_ids(course_id)
    progress = course_progresses.find_by_course_id(course_id)
    return [] if progress.blank?
    progress.completed_lessons.collect(&:lesson_id)
  end

  def completed_course_ids
    progress = course_progresses.where.not(completed_at: nil)
    return [] if progress.blank?
    progress.collect(&:course_id)
  end

  def current_roles
    roles.pluck(:name).join(", ")
  end

  def preferred_language
    language = profile.language
    language.blank? ? "English" : language.name
  end
end
