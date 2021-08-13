class FooterLink < ApplicationRecord
  belongs_to :organization

  validates :label, presence: true
  validates :url, presence: true
end
