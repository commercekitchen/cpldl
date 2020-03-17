# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.max_length_for(attr)
    self.validators_on(attr).first.options[:maximum]
  end
end
