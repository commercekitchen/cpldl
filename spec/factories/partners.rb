# frozen_string_literal: true

FactoryBot.define do
  factory :partner do
    name { 'Test Partner' }
    association :organization, :accepts_partners
  end
end
