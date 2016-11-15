# == Schema Information
#
# Table name: programs
#
#  id                  :integer          not null, primary key
#  program_name        :string
#  location_field_name :string
#  location_required   :boolean          default(FALSE)
#  student_program     :boolean          default(FALSE)
#  organization_id     :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Program < ActiveRecord::Base
  has_many :users
  has_many :program_locations, dependent: :destroy
  belongs_to :organization
  validates :program_name, presence: true
  validates :location_field_name, presence: true, if: :location_required

  accepts_nested_attributes_for :program_locations

  scope :for_subdomain, -> (subdomain) { joins(:organization).where("organizations.subdomain = ?", subdomain) }
end
