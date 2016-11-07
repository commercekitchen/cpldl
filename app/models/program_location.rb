# == Schema Information
#
# Table name: program_locations
#
#  id            :integer          not null, primary key
#  location_name :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  enabled       :boolean          default(TRUE)
#  program_id    :integer
#

class ProgramLocation < ActiveRecord::Base
  belongs_to :program
  has_many :users
  validates :location_name, presence: true
end
