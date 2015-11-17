# == Schema Information
#
# Table name: contents
#
#  id          :integer          not null, primary key
#  body        :text
#  summary     :string
#  language_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  cms_page_id :integer
#  course_id   :integer
#  lesson_id   :integer
#

FactoryGirl.define do
  factory(:content) do
    body "What a great body!"
    language_id 1
  end
end
