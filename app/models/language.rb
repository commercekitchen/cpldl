class Language < ActiveRecord::Base
  has_many :course

  validates :name, presence: true
end
