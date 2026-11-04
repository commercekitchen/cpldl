# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SafeCsv do
  describe '.sanitize' do
    ['=1+1', '+1', '-1', '@SUM(A1)', "\tcmd", "\rcmd"].each do |value|
      it "neutralizes #{value.inspect}" do
        expect(described_class.sanitize(value)).to eq("'#{value}")
      end
    end

    it 'leaves ordinary strings alone' do
      expect(described_class.sanitize('user@example.com')).to eq('user@example.com')
    end

    it 'leaves non-strings alone' do
      expect(described_class.sanitize(-1)).to eq(-1)
      expect(described_class.sanitize(nil)).to be_nil
    end
  end

  it 'sanitizes rows written through generate' do
    csv = described_class.generate do |out|
      out << ['=bad', 'ok']
      out.add_row [2, '@bad']
    end

    expect(csv).to eq("'=bad,ok\n2,'@bad\n")
  end

  it 'sanitizes generate_line' do
    expect(described_class.generate_line(['+bad', 3])).to eq("'+bad,3\n")
  end
end
