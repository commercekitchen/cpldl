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
  has_many :cms_pages
  has_many :library_locations
  has_many :programs
  has_many :schools
  has_many :organization_courses
  has_many :courses, through: :organization_courses
  validate 

  def user_count
    users.count
  end

  def admin_user_emails
    users.select{|u| u.has_role?(:admin, self)}.map(&:email)
  end

  def has_student_programs?
    programs.map(&:student_program?).any?{ |p| p }
  end

  private

  def users
    User.where(organization_id: id)
  end
end
