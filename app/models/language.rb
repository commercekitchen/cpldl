# frozen_string_literal: true

# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Language < ApplicationRecord
  has_many :courses, dependent: :restrict_with_exception
  has_many :cms_pages, dependent: :restrict_with_exception

  validates :name, presence: true
end
