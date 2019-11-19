# frozen_string_literal: true

require 'rails_helper'

describe Partner do
  let(:org) { FactoryBot.create(:organization) }
  let(:partner) { Partner.new(organization: org, name: 'Test Partner') }

  it 'should be valid with valid attributes' do
    expect(partner).to be_valid
  end

  it 'should be invalid without an organization' do
    partner.organization = nil
    expect(partner).to_not be_valid
  end

  it 'should be invalid without a name' do
    partner.name = nil
    expect(partner).to_not be_valid
  end
end
