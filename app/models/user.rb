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
end
