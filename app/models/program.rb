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
#  parent_type         :integer
#

class Program < ActiveRecord::Base
  enum parent_type: [:seniors, :young_adults, :students_and_parents]
  PARENT_TYPES = {
    "Programs for Seniors" => :seniors,
    "Programs for Young Adults" => :young_adults,
    "Programs for Students and Parents" => :students_and_parents
  }

  has_many :users
  has_many :program_locations, dependent: :destroy
  belongs_to :organization
  validates :program_name, presence: true

  accepts_nested_attributes_for :program_locations

  scope :for_subdomain, -> (subdomain) { joins(:organization).where("organizations.subdomain = ?", subdomain) }
end
