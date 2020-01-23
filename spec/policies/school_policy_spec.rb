# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolPolicy, type: :policy do
  it_behaves_like 'AdminOnly Policy', { model: School }
end
