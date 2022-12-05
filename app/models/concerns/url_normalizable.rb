# frozen_string_literal: true

module UrlNormalizable
  extend ActiveSupport::Concern

  def normalize_url
    url.strip!
    uri = URI.parse(url)
    
    if uri.scheme.nil? && uri.host.nil?
      # URL provided without scheme (ex/ 'www.example.com' instead of 'https://www.example.com')
      self.url = "https://#{url}"
    end
  end
end