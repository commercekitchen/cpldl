# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id           :integer          not null, primary key
#  first_name   :string(30)       not null
#  last_name    :string(30)       not null
#  organization :string(50)       not null
#  city         :string(30)       not null
#  state        :string(2)        not null
#  email        :string(30)       not null
#  phone        :string(20)
#  comments     :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory(:contact) do
    first_name 'Alan'
    last_name 'Turing'
    organization 'New York Public Library'
    city 'New York'
    state 'NY'
    email 'ny@example.com'
    phone '5551231234'
    comments "We'd like one too!"
  end
end
