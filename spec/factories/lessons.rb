FactoryGirl.define do
  factory(:lesson) do
    title "Lesson 1"
    summary "Lesson summary"
    duration 90
    lesson_order 1
    story_line { fixture_file_upload(Rails.root.join("spec", "fixtures", "BasicSearch1.zip"), "application/zip") }
  end
end
