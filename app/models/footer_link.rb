class FooterLink < ApplicationRecord
  belongs_to :organization
  belongs_to :language

  validates :label, presence: true
  validates :url, presence: true
end
