FactoryGirl.define do

  factory :course do
    title "Computer Course"
    meta_desc "A first course in computing"
    summary "In this course you will..."
    description "Description"
    contributor "John Doe"
    level "Beginner"
    language
  end

  factory :course_with_lessons, class: Course do
    title "Computer Course"
    meta_desc "A first course in computing"
    summary "In this course you will..."
    description "Description"
    contributor "John Doe"
    level "Beginner"
    language

    after(:create) do |course|
      create(:lesson, course: course, lesson_order: 1)
      create(:lesson, course: course, lesson_order: 2)
      create(:lesson, course: course, lesson_order: 3)
    end
  end
end
