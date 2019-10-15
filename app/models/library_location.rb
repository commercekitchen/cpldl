# frozen_string_literal: true

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

class LibraryLocation < ApplicationRecord
  belongs_to :organization, required: false
  validates :name, :zipcode, presence: true

  default_scope { order(:sort_order) }
end
