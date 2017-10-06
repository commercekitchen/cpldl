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
#

class LibraryLocation < ActiveRecord::Base
  belongs_to :organization
  validates :name, :zipcode, presence: true

  default_scope { order(:name) }
end
