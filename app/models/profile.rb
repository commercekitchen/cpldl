# == Schema Information
#
# Table name: profiles
#
#  id                  :integer          not null, primary key
#  first_name          :string
#  zip_code            :string
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  language_id         :integer
#  library_location_id :integer
#  acting_as           :integer          default(0)
#  last_name           :string
#  phone               :string
#  street_address      :string
#  city                :string
#  state               :string
#  library_card_number :string
#  student_id          :string
#  date_of_birth       :datetime
#  grade               :integer
#  school_id           :integer
#

class Profile < ActiveRecord::Base
  belongs_to :user
  belongs_to :language
  belongs_to :library_location
  belongs_to :school

  validates :first_name, presence: true
  validates :zip_code, format: { with: /\A\d{5}-\d{4}|\A\d{5}\z/, message: "should be ##### or #####-####" },
    allow_blank: true

  validates :student_id_number, presence: true, if: :acting_as_parent?
  
  with_options if: :acting_as_student? do |student|
    student.validates :date_of_birth, presence: true
    student.validates :grade,         presence: true
    student.validates :student_id,    presence: true
    student.validates :school_id,     presence: true
  end

  def acting_as_parent?
    (user.has_role? "parent") unless user.blank?
  end

  def acting_as_student?
    (user.has_role? "student") unless user.blank?
  end
end
