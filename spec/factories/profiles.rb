# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  first_name  :string
#  zip_code    :string
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :integer
#

FactoryGirl.define do
  factory(:profile) do
    first_name "Jane"
    zip_code "90210"
  end
end
