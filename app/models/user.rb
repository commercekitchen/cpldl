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
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  rolify
  has_one :profile, dependent: :destroy
  has_many :course_progresses, dependent: :destroy
  accepts_nested_attributes_for :profile
  validates_associated :profile

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
end
