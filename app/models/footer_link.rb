# frozen_string_literal: true

class FooterLink < ApplicationRecord
  belongs_to :organization
  belongs_to :language

  validates :label, presence: true
  validates :url, presence: true

  before_save :normalize_url

  private

  def normalize_url
    uri = URI.parse(url)
    
    if uri.scheme.nil? && uri.host.nil?
      # URL provided without scheme (ex/ 'www.example.com' instead of 'https://www.example.com')
      self.url = "https://#{url}"
    end
  end
end
