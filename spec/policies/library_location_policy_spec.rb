# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryLocationPolicy, type: :policy do
  it_behaves_like 'AdminOnly Policy', { model: LibraryLocation }
end
