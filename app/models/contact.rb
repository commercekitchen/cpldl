# frozen_string_literal: true

class Contact < ApplicationRecord
  validates :first_name, presence: true, length: { maximum: 30 }
  validates :last_name, presence: true, length: { maximum: 30 }
  validates :organization, presence: true, length: { maximum: 50 }
  validates :city, presence: true, length: { maximum: 30 }
  validates :state, presence: true, length: { maximum: 2 }
  validates :email, presence: true, length: { maximum: 50 }
  validates :email, email: true, if: Proc.new { |c| c.email.present? }
  validates :phone, length: { maximum: 20 }
  validates :comments, presence: true, length: { maximum: 2048 }

  def full_name
    "#{first_name} #{last_name}"
  end

  def city_state
    "#{city}, #{state}"
  end
end
