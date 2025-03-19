# frozen_string_literal: true

require 'mail'

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      m = Mail::Address.new(value)
      # We must check that value contains a domain, the domain has at least
      # one '.' and that value is an email address
      r = !m.domain.nil? && m.domain.match('\.') && m.address == value
    rescue StandardError
      r = false
    end
    record.errors.add(attribute, (options[:message] || 'is invalid')) unless r
  end
end
