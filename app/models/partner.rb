# frozen_string_literal: true

class Partner < ApplicationRecord
  belongs_to :organization

  validates :name, presence: true
end
