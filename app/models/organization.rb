# frozen_string_literal: true

class Organization < ApplicationRecord
  include Storext.model

  resourcify

  store_attributes :preferences do
    footer_logo_file_name        String
    footer_logo_file_size        Integer
    footer_logo_link             String
    footer_logo_content_type     String
    user_survey_enabled          Boolean, default: false
    user_survey_link             String
    spanish_survey_link          String
    custom_certificate_enabled   Boolean, default: false
    phone_number_users_enabled   Boolean, default: false
    custom_recommendation_survey Boolean, default: false
    custom_topics                Boolean, default: false
    survey_required              Boolean, default: false
  end

  # store_accessor :preferences, :footer_logo_file_name, :footer_logo_link, :footer_logo_content_type,
  # :user_survey_enabled, :user_survey_button_text, :user_survey_link

  has_many :cms_pages, dependent: :destroy
  has_many :library_locations, dependent: :destroy
  has_many :programs, dependent: :destroy
  has_many :schools, dependent: :destroy
  has_many :courses, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :partners, dependent: :destroy
  has_many :footer_links, dependent: :destroy

  has_many :lessons, through: :courses
  has_many :topics

  scope :using_lesson, ->(lesson_id) { includes(courses: :lessons).where(lessons: { parent_id: lesson_id }) }
  scope :using_course, ->(course_id) { includes(:courses).where(courses: { parent_id: course_id }) }

  has_attached_file :footer_logo

  validates :name, presence: true
  validates :subdomain, presence: true

  validates_attachment_content_type :footer_logo, content_type: ['image/png', 'image/jpeg'], message: 'should be png or jpeg format.'
  validates_attachment_size :footer_logo, in: 0.megabytes..2.megabytes

  validates :footer_logo_link, url: { allow_blank: true }
  after_validation :clean_up_paperclip_errors

  validates :user_survey_link, url: { allow_blank: true }
  validates :user_survey_link, presence: { if: :user_survey_enabled? }
  validates :spanish_survey_link, url: { allow_blank: true }

  def user_count
    users.count
  end

  def admin_user_emails
    users.select { |u| u.has_role?(:admin, self) }.map(&:email)
  end

  def student_programs?
    programs.where(parent_type: :students_and_parents).present?
  end

  def authentication_key_field(admin = false)
    if library_card_login? && !admin
      :library_card_number
    elsif phone_number_users_enabled? && !admin
      :phone_number
    else
      :email
    end
  end

  def password_key_field(admin = false)
    if library_card_login? && !admin
      :library_card_pin
    else
      :password
    end
  end

  # https://github.com/thoughtbot/paperclip/commit/2aeb491fa79df886a39c35911603fad053a201c0
  def clean_up_paperclip_errors
    errors.delete(:footer_logo_content_type)
    errors.delete(:footer_logo_file_size)
  end

  def assignable_roles
    default_roles = %w[Admin User Trainer]

    if student_programs?
      default_roles + %w[Student Parent]
    else
      default_roles
    end
  end

  def training_site_link
    training_site_base = Rails.application.credentials[Rails.env.to_sym][:training_site_base]
    training_site_domain = Rails.application.credentials[Rails.env.to_sym][:training_site_domain]

    if use_subdomain_for_training_site
      [training_site_base, subdomain, training_site_domain].join('.')
    else
      [training_site_base, training_site_domain].join('.')
    end
  end

  def survey_url(locale)
    if locale == :es
      spanish_survey_link.blank? ? user_survey_link : spanish_survey_link
    else
      user_survey_link
    end
  end

  def self.pla
    find_by(subdomain: 'www')
  end
end
