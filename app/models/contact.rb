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

class Contact < ApplicationRecord
  validates :first_name, presence: true, length: { maximum: 30 }
  validates :last_name, presence: true, length: { maximum: 30 }
  validates :organization, presence: true, length: { maximum: 50 }
  validates :city, presence: true, length: { maximum: 30 }
  validates :state, presence: true, length: { maximum: 2 }
  validates :email, email: true, presence: true, length: { maximum: 50 }
  validates :phone, length: { maximum: 20 }
  validates :comments, presence: true, length: { maximum: 2048 }

  def full_name
    "#{first_name} #{last_name}"
  end

  def city_state
    "#{city}, #{state}"
  end
end
