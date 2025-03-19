# frozen_string_literal: true

FactoryBot.define do
  factory(:contact) do
    first_name { 'Alan' }
    last_name { 'Turing' }
    organization { 'New York Public Library' }
    city { 'New York' }
    state { 'NY' }
    email { 'ny@example.com' }
    phone { '5551231234' }
    comments { "We'd like one too!" }
  end
end
