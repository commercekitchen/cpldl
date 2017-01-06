# == Schema Information
#
# Table name: organizations
#
#  id               :integer          not null, primary key
#  name             :string
#  subdomain        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  branches         :boolean
#  accepts_programs :boolean
#

class Organization < ActiveRecord::Base
  resourcify
  has_many :cms_pages, dependent: :destroy
  has_many :library_locations, dependent: :destroy
  has_many :programs, dependent: :destroy
  has_many :schools, dependent: :destroy
  has_many :organization_courses
  has_many :courses, through: :organization_courses
  has_many :users, dependent: :destroy
  validate 

  def user_count
    users.count
  end

  def admin_user_emails
    users.select{|u| u.has_role?(:admin, self)}.map(&:email)
  end

  def has_student_programs?
    programs.map(&:parent_type).any?{ |p| p.to_sym == :students_and_parents }
  end

  private

  def users
    User.where(organization_id: id)
  end
end
