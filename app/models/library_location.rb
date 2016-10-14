# == Schema Information
#
# Table name: library_locations
#
#  id         :integer          not null, primary key
#  name       :string
#  zipcode    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LibraryLocation < ActiveRecord::Base
  belongs_to :organization
  validates :name, :zipcode, presence: true
end
