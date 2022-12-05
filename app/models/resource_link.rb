# frozen_string_literal: true

class ResourceLink < ApplicationRecord
  include UrlNormalizable

  belongs_to :course

  validates :label, presence: true
  validates :url, presence: true

  before_save :normalize_url
end
