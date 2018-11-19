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
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#  token                  :string
#  organization_id        :integer
#  school_id              :integer
#  program_location_id    :integer
#  acting_as              :string
#  library_card_number    :string
#  student_id             :string
#  date_of_birth          :datetime
#  grade                  :integer
#  quiz_responses_object  :text
#  program_id             :integer
#  library_card_pin       :string
#

class User < ActiveRecord::Base
  require "securerandom"
  include PgSearch
  # TODO: determine lockable? functionality and add to search
  pg_search_scope :search_users, against: [:email],
                      associated_against: { profile: [:first_name],
                                              roles: [:name] },
                                              using: { tsearch: { prefix: true },
                                                    dmetaphone: { any_word: true },
                                                       trigram: { threshold: 0.1 } }

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  rolify
  belongs_to :organization
  belongs_to :school
  belongs_to :program_location
  belongs_to :program
  has_one :profile, dependent: :destroy
  has_many :course_progresses, dependent: :destroy
  accepts_nested_attributes_for :profile
  validates_associated :profile
  before_create :add_token_to_user

  delegate :library_card_login?, to: :organization

  # Validate card number and pin for library card logins
  validates_format_of :library_card_number, with: /\A[0-9]{13}\z/, if: :library_card_login?
  validates_format_of :library_card_pin, with: /\A[0-9]{4}\z/, if: :library_card_login?

  # Serialized hash of quiz responses
  serialize :quiz_responses_object

  ROLES = %w(Admin Trainer User Parent Student)

  ### Devise overrides to allow library card number login
  # TODO: Pull this into a concern

  attr_accessor :library_card_pin
  attr_writer :login

  def login
    @login || (
      if self.organization.present? && self.organization.library_card_login?
        self.library_card_number
      else
        self.email
      end
    )
  end

  def login_type_string
    'foobar'
  end

  def email_required?
    if organization.library_card_login?
      false
    else
      super
    end
  end

  def email_changed?
    if organization.library_card_login?
      false
    else
      super
    end
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["library_card_number = :value OR email = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:library_card_number) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  ###

  def organization_id_to_be_deleted
    roles.find_by_resource_type("Organization").resource_id
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
    profile.blank? ? language = nil : language = profile.language
    language.blank? ? "English" : language.name
  end

  def subdomain
    organization.subdomain
  end

  def reportable_role?(org)
    return true if self.has_role?(:user, org) || self.has_role?(:parent, org) || self.has_role?(:student, org)
    false
  end

  private

    def add_token_to_user
      self.token = SecureRandom.uuid if self.token.blank?
    end
end
