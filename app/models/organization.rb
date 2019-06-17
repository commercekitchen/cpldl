# == Schema Information
#
# Table name: organizations
#
#  id                      :integer          not null, primary key
#  name                    :string
#  subdomain               :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  branches                :boolean
#  accepts_programs        :boolean
#  library_card_login      :boolean          default(FALSE)
#  accepts_custom_branches :boolean          default(FALSE)
#  login_required          :boolean          default(TRUE)
#

class Organization < ActiveRecord::Base
  include Storext.model

  resourcify

  store_attributes :preferences do
    footer_logo_file_name     String
    footer_logo_link          String
    footer_logo_content_type  String
    user_survey_enabled       Boolean,  default: false
    user_survey_link          String
  end

  # store_accessor :preferences, :footer_logo_file_name, :footer_logo_link, :footer_logo_content_type,
    # :user_survey_enabled, :user_survey_button_text, :user_survey_link

  has_many :cms_pages, dependent: :destroy
  has_many :library_locations, dependent: :destroy
  has_many :programs, dependent: :destroy
  has_many :schools, dependent: :destroy
  has_many :courses
  has_many :users, dependent: :destroy
  has_many :categories, dependent: :destroy

  scope :using_lesson, ->(lesson_id) { includes(courses: :lessons).where(lessons: { parent_id: lesson_id }) }
  scope :using_course, ->(course_id) { includes(:courses).where(courses: { parent_id: course_id }) }

  has_attached_file :footer_logo

  validates_attachment_content_type :footer_logo, content_type: ["image/png", "image/jpeg"], message: "should be png or jpeg format."
  validates :footer_logo_link, url: { allow_blank: true }
  after_validation :clean_up_paperclip_errors

  validates :user_survey_link, url: { allow_blank: true }
  validates_presence_of :user_survey_link, if: :user_survey_enabled?

  def user_count
    users.count
  end

  def admin_user_emails
    users.select { |u| u.has_role?(:admin, self) }.map(&:email)
  end

  def has_student_programs?
    programs.map(&:parent_type).any? { |p| p.to_sym == :students_and_parents }
  end

  def base_site?
    subdomain == "www"
  end

  def authentication_key_field
    if library_card_login?
      :library_card_number
    else
      :email
    end
  end

  def password_key_field
    if library_card_login?
      :library_card_pin
    else
      :password
    end
  end

  # https://github.com/thoughtbot/paperclip/commit/2aeb491fa79df886a39c35911603fad053a201c0
  def clean_up_paperclip_errors
    errors.delete(:footer_logo_content_type)
  end
end
