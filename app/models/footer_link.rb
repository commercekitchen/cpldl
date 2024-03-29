# frozen_string_literal: true

class FooterLink < ApplicationRecord
  include UrlNormalizable

  belongs_to :organization
  belongs_to :language

  validates :label, presence: true
  validates :url, presence: true

  before_save :normalize_url
end
