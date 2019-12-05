# frozen_string_literal: true

class LibraryLocation < ApplicationRecord
  belongs_to :organization, optional: true
  validates :name, :zipcode, presence: true

  default_scope { order(:sort_order) }
end
