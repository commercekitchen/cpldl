# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :language do
    name "English"
  end

  factory :spanish_lang , class: Language do
    name "Spanish"
  end
end
