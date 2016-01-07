# == Schema Information
#
# Table name: courses
#
#  id             :integer          not null, primary key
#  title          :string(90)
#  seo_page_title :string(90)
#  meta_desc      :string(156)
#  summary        :string(156)
#  description    :text
#  contributor    :string
#  pub_status     :string           default("D")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :integer
#  level          :string
#  notes          :text
#  slug           :string
#  course_order   :integer
#  pub_date       :datetime
#  format         :string
#

FactoryGirl.define do

  factory :course do
    title "Computer Course"
    meta_desc "A first course in computing"
    summary "In this course you will..."
    description "Description"
    contributor "John Doe"
    level "Beginner"
    format "D"
    language
    pub_status "P"
  end

  factory :draft_course, class: Course do
    title "Draft Course"
    meta_desc "A draft course in computing"
    summary "In this course you will..."
    description "Description"
    contributor "John Doe"
    level "Beginner"
    format "D"
    language
    pub_status "D"
  end

  factory :course_with_lessons, class: Course do
    title "Computer Course"
    meta_desc "A first course in computing"
    summary "In this course you will..."
    description "Description"
    contributor "John Doe"
    level "Beginner"
    format "D"
    language
    pub_status "P"

    after(:create) do |course|
      create(:lesson, course: course, lesson_order: 1)
      create(:lesson, course: course, lesson_order: 2)
      create(:lesson, course: course, lesson_order: 3)
    end
  end
end
