# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProgramPolicy, type: :policy do
  it_behaves_like 'AdminOnly Policy', { model: Program }
end
