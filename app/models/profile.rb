class Profile < ActiveRecord::Base
  belongs_to :user
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates_format_of :zip_code, with: /\A\d{5}-\d{4}|\A\d{5}\z/,
    message: "should be ##### or #####-####", allow_blank: true
end
