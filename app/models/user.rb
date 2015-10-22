class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  rolify
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  validates_associated :profile
end
