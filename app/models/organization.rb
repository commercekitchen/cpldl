# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string
#  subdomain  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Organization < ActiveRecord::Base
  resourcify
  has_many :cms_pages
  has_many :library_locations
  validate 

  def user_count
    users.count
  end

  def admin_user_emails
    users.select{|u| u.has_role?(:admin, self)}.map(&:email)
  end

  private

  def users
    User.where(organization_id: id)
  end
end
