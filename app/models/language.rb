# frozen_string_literal: true

class Language < ApplicationRecord
  has_many :courses, dependent: :restrict_with_exception
  has_many :cms_pages, dependent: :restrict_with_exception

  validates :name, presence: true
end
