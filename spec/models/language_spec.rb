# frozen_string_literal: true

require 'rails_helper'

describe Language do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
