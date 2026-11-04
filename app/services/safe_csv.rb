# frozen_string_literal: true

require 'csv'

# Drop-in replacements for CSV.generate / CSV.generate_line that neutralize
# spreadsheet formula injection (OWASP "CSV Injection"): any string cell that
# a spreadsheet would interpret as a formula is prefixed with a single quote.
module SafeCsv
  FORMULA_PREFIX = /\A[=+\-@\t\r]/.freeze

  def self.sanitize(value)
    value.is_a?(String) && value.match?(FORMULA_PREFIX) ? "'#{value}" : value
  end

  def self.row(values)
    values.map { |value| sanitize(value) }
  end

  def self.generate_line(values, **options)
    CSV.generate_line(row(values), **options)
  end

  def self.generate(**options)
    CSV.generate(**options) { |csv| yield Writer.new(csv) }
  end

  class Writer
    def initialize(csv)
      @csv = csv
    end

    def <<(values)
      @csv << SafeCsv.row(values)
      self
    end
    alias add_row <<
  end
end
