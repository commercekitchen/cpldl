# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoryPolicy, type: :policy do
  it_behaves_like 'AdminOnly Policy', { model: Category }
end
