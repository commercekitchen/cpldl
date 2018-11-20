# == Schema Information
#
# Table name: library_locations
#
#  id              :integer          not null, primary key
#  name            :string
#  zipcode         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#  sort_order      :integer          default(0)
#  custom          :boolean          default(FALSE)
#

class LibraryLocation < ActiveRecord::Base
  belongs_to :organization
  validates :name, :zipcode, presence: true

  default_scope { order(:sort_order) }
end
