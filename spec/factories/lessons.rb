FactoryGirl.define do
  factory(:lesson) do
    title "Lesson 1"
    summary "Lesson summary"
    duration 90
    lesson_order 1
    story_line File.new("spec/fixtures/BasicSearch1.zip")
  end
end
