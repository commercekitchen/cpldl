class LanguageCourse < ActiveRecord::Base
  has_many :language
  has_many :course
end
