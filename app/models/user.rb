# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  email                         :string           default("")
#  encrypted_password            :string           default(""), not null
#  reset_password_token          :string
#  reset_password_sent_at        :datetime
#  remember_created_at           :datetime
#  sign_in_count                 :integer          default(0), not null
#  current_sign_in_at            :datetime
#  last_sign_in_at               :datetime
#  current_sign_in_ip            :string
#  last_sign_in_ip               :string
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  confirmation_sent_at          :datetime
#  unconfirmed_email             :string
#  failed_attempts               :integer          default(0), not null
#  unlock_token                  :string
#  locked_at                     :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  profile_id                    :integer
#  quiz_modal_complete           :boolean          default(FALSE)
#  invitation_token              :string
#  invitation_created_at         :datetime
#  invitation_sent_at            :datetime
#  invitation_accepted_at        :datetime
#  invitation_limit              :integer
#  invited_by_id                 :integer
#  invited_by_type               :string
#  invitations_count             :integer          default(0)
#  token                         :string
#  organization_id               :integer
#  school_id                     :integer
#  program_location_id           :integer
#  acting_as                     :string
#  library_card_number           :string
#  student_id                    :string
#  date_of_birth                 :datetime
#  grade                         :integer
#  quiz_responses_object         :text
#  program_id                    :integer
#  encrypted_library_card_pin    :string
#  encrypted_library_card_pin_iv :string
#

class User < ApplicationRecord
  require 'securerandom'
  include PgSearch::Model
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
  belongs_to :school, optional: true
  belongs_to :program_location, optional: true
  belongs_to :program, optional: true

  has_one :profile, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :profile
  validates_associated :profile

  has_many :course_progresses, dependent: :destroy
  before_create :add_token_to_user

  # Encrypt library card pin for security
  attr_encrypted :library_card_pin, key: Rails.application.secrets.secret_key_base[0..31]

  # Save blank emails as NULL
  nilify_blanks only: [:email]

  before_validation :set_password_from_pin, if: :library_card_login?
  # Validate card number and pin for library card logins
  validates :library_card_number, format: { with: /\A[0-9]{7,}\z/, if: :library_card_login? }
  validates :library_card_pin, format: { with: /\A[0-9]{4}\z/, if: :library_card_login? }

  # Serialized hash of quiz responses
  serialize :quiz_responses_object

  # Expose some information from profile
  delegate :library_location_name, :library_location_zipcode, to: :profile, allow_nil: true

  ROLES = %w[Admin Trainer User Parent Student].freeze

  ### Devise overrides to allow library card number login
  # TODO: Pull this into a concern

  attr_writer :login

  def login
    @login || (
      if self.organization.present? && library_card_login?
        self.library_card_number
      else
        self.email
      end
    )
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
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(['library_card_number = :value OR email = :value', { value: login.downcase }]).first
    elsif conditions.key?(:library_card_number) || conditions.key?(:email)
      where(conditions.to_h).first
    end
  end

  def valid_password?(password)
    # Library card login admins registered before Jun 5, 2019 use [email, password]
    # for authentication but their password is MD5 hexdigested.
    # As of Jun 5, 2019, we dont digest library card admin password because due to
    # issues with password reset and password update
    # Here's temporary solution to allow users with stale password access
    if organization.library_card_login? && admin?
      valid = Devise::Encryptor.compare(self.class, encrypted_password, md5_digest(password))
      return true if valid
    end

    # This is the main password validation
    generated_password = library_card_login? ? md5_digest(password) : password
    Devise::Encryptor.compare(self.class, encrypted_password, generated_password)
  end

  def library_card_login?
    organization.library_card_login? && !admin?
  end

  ###

  def organization_id_to_be_deleted
    roles.find_by(resource_type: 'Organization').resource_id
  end

  def tracking_course?(course_id)
    course_progresses.where(course_id: course_id, tracked: true).count > 0
  end

  def completed_lesson_ids(course_id)
    progress = course_progresses.find_by(course_id: course_id)
    return [] if progress.blank?

    progress.completed_lessons.collect(&:lesson_id)
  end

  def completed_course_ids
    progress = course_progresses.where.not(completed_at: nil)
    return [] if progress.blank?

    progress.collect(&:course_id)
  end

  def current_roles
    roles.pluck(:name).join(', ')
  end

  def preferred_language
    language = profile.blank? ? nil : profile.language
    language.blank? ? 'English' : language.name
  end

  delegate :subdomain, to: :organization

  def admin?
    has_role?(:admin, organization)
  end

  def reportable_role?(org)
    return true if self.has_role?(:user, org) || self.has_role?(:parent, org) || self.has_role?(:student, org)

    false
  end

  private

  def add_token_to_user
    self.token = SecureRandom.uuid if self.token.blank?
  end

  def set_password_from_pin
    return unless library_card_pin_changed?

    hashed_pin = md5_digest(library_card_pin)
    self.password = hashed_pin
    self.password_confirmation = hashed_pin
  end

  def md5_digest(password, limit = 10)
    Digest::MD5.hexdigest(password).first(limit)
  end
end
