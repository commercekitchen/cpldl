# == Schema Information
#
# Table name: lessons
#
#  id                      :integer          not null, primary key
#  lesson_order            :integer
#  title                   :string(90)
#  duration                :integer
#  course_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string
#  summary                 :string(156)
#  story_line              :string(156)
#  seo_page_title          :string(90)
#  meta_desc               :string(156)
#  is_assessment           :boolean
#  story_line_file_name    :string
#  story_line_content_type :string
#  story_line_file_size    :integer
#  story_line_updated_at   :datetime
#  pub_status              :string
#  parent_lesson_id        :integer
#

FactoryGirl.define do
  factory :lesson do
    title "Lesson 1"
    summary "Lesson summary"
    duration 90
    lesson_order 1
    pub_status "P"
    story_line { fixture_file_upload(Rails.root.join("spec", "fixtures", "BasicSearch1.zip"), "application/zip") }
  end

  factory :lesson_without_story, class: Lesson do
    title "Lesson without story"
    summary "Lesson summary"
    pub_status "P"
    duration 90
    lesson_order 1
  end
end
