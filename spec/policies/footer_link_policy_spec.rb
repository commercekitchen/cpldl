# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FooterLinkPolicy, type: :policy do
  it_behaves_like 'AdminOnly Policy', { model: FooterLink }
end
